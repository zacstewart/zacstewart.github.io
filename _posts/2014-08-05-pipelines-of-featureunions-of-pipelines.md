---
layout: post
title: "Pipelines of FeatureUnions of Pipelines"
---

A powerful feature of scikit-learn is the ability to chain transformers and estimators together in such a way that you can use them as a single unit. This comes in very handy when you need to jump through a few hoops of data extraction, transformation, normalization, and finally train your model (or use it to generate predictions). 

When I first started participating in Kaggle competitions, I would invariably get started with some code that looked similar to this:

```python
train = read_file('data/train.tsv')
train_y = extract_targets(train)
train_essays = extract_essays(train)
train_tokens = get_tokens(train_essays)
train_features = extract_feactures(train)
classifier = MultinomialNB()

scores = []
train_idx, cv_idx in KFold():
  classifier.fit(train_features[train_idx], train_y[train_idx])
  scores.append(model.score(train_features[cv_idx], train_y[cv_idx]))

print("Score: {}".format(np.mean(scores)))
```

Often, this would yield a pretty decent score for a first submission. Then I'd want to try engineering some more features. Let's say in instead of text n-gram counts, I want [tf–idf][1], and in addition, I want to include overall essay length, and then misspelling counts. Well, I can just tack those into the implementation of `extract_features`. I'd extract a matrix of features for each of those ideas and then concatenate them along axis 1. Easy.

Next, I'd find myself normalizing or scaling features, and then realizing that I want to scale some features and normalize others. Before I'd realize it, it would be 2am and I'd be trying to keep track of matrix column indices by hand so that I can try something out real quick. I'd cross validate my model again, only to realize that it hurt my score, so never mind. Maybe I should fiddle with some of the model hyperparameters or something, until finally I `git commit -am "WIP going to bed"`.

# Pipelines

Using a [Pipeline][2] simplifies this process. Instead of manually running through each of these steps, and then tediously repeating them on the test set, you get a nice, declarative interface where it's easy to see the entire model. This example extracts the text documents, tokenizes them, counts the tokens, and then performs a tf-idf transformation before passing the resulting features along to a multinomial naive Bayes classifier:

```python
pipeline = Pipeline([
  ('extract_essays', EssayExractor()),
  ('counts', CountVectorizer()),
  ('tf_idf', TfidfTransformer()),
  ('classifier', MultinomialNB())
])

train = read_file('data/train.tsv')
train_y = extract_targets(train)
scores = []
train_idx, cv_idx in KFold():
  model.fit(train[train_idx], train_y[train_idx])
  scores.append(model.score(train[cv_idx], train_y[cv_idx]))

print("Score: {}".format(np.mean(scores)))
```

This pipeline has what I think of as a linear shape. The data flows straight through each step, until it reaches the classifier.

![Simple scikit-learn Pipeline](/images/pipelines-of-featureunions-of-pipelines/simple-pipeline.svg)

# FeatureUnions

Like I said before, I usually want to extract more features, and that means parallel processes that need to be performed with the data before putting the results together. Using a [FeatureUnion][3], you can model these parallel processes, which are often Pipelines themselves:

```python
pipeline = Pipeline([
  ('extract_essays', EssayExractor()),
  ('features', FeatureUnion([
    ('ngram_tf_idf', Pipeline([
      ('counts', CountVectorizer()),
      ('tf_idf', TfidfTransformer())
    ])),
    ('essay_length', LengthTransformer()),
    ('misspellings', MispellingCountTransformer())
  ])),
  ('classifier', MultinomialNB())
])
```

This example feeds the output of the `extract_essays` step into each of the `ngram_tf_idf`, `essay_length`, and `misspellings` steps and concatenates their outputs (along axis 1) before feeding it into the classifier.

![scikit-learn Pipeline with a FeatureUnion](/images/pipelines-of-featureunions-of-pipelines/featureunion-pipelines.svg)

Usually, I end up with several layers of nested Pipelines and FeatureUnions. For example, here's a crazy Pipeline I pulled from a project I am currently working on:

```python
pipeline = Pipeline([
    ('features', FeatureUnion([
        ('continuous', Pipeline([
            ('extract', ColumnExtractor(CONTINUOUS_FIELDS)),
            ('scale', Normalizer())
        ])),
        ('factors', Pipeline([
            ('extract', ColumnExtractor(FACTOR_FIELDS)),
            ('one_hot', OneHotEncoder(n_values=5)),
            ('to_dense', DenseTransformer())
        ])),
        ('weekday', Pipeline([
            ('extract', DayOfWeekTransformer()),
            ('one_hot', OneHotEncoder()),
            ('to_dense', DenseTransformer())
        ])),
        ('hour_of_day', HourOfDayTransformer()),
        ('month', Pipeline([
            ('extract', ColumnExtractor(['datetime'])),
            ('to_month', DateTransformer()),
            ('one_hot', OneHotEncoder()),
            ('to_dense', DenseTransformer())
        ])),
        ('growth', Pipeline([
            ('datetime', ColumnExtractor(['datetime'])),
            ('to_numeric', MatrixConversion(int)),
            ('regression', ModelTransformer(LinearRegression()))
        ]))
    ])),
    ('estimators', FeatureUnion([
        ('knn', ModelTransformer(KNeighborsRegressor(n_neighbors=5))),
        ('gbr', ModelTransformer(GradientBoostingRegressor())),
        ('dtr', ModelTransformer(DecisionTreeRegressor())),
        ('etr', ModelTransformer(ExtraTreesRegressor())),
        ('rfr', ModelTransformer(RandomForestRegressor())),
        ('par', ModelTransformer(PassiveAggressiveRegressor())),
        ('en', ModelTransformer(ElasticNet())),
        ('cluster', ModelTransformer(KMeans(n_clusters=2)))
    ])),
    ('estimator', KNeighborsRegressor())
])
```

# Custom Transformers

Many of the steps in the previous examples include transformers that don't come with scikit-learn. The ColumnExtractor, DenseTransformer, and ModelTransformer, to name a few, are all custom transformers that I wrote. A custom transformer is just an object that responds to `fit`, `transform`, and `fit_transform`.

Sometimes these transformers are very simple, like HourOfDayTransformer, which just extracts the hour components out of a vector of datetime objects. In this case, the transformer is "stateless" (it doesn't need to be fitted) and `fit` is a no-op:

```python
class HourOfDayTransformer(TransformerMixin):

    def transform(self, X, **transform_params):
        hours = DataFrame(X['datetime'].apply(lambda x: x.hour))
        return hours

    def fit_transform(self, X, y=None, **fit_params):
        self.fit(X, y, **fit_params)
        return self.transform(X)

    def fit(self, X, y=None, **fit_params):
        pass
```

However, sometimes these transformers do need to be fitted. Let's take a look at my ModelTransformer. I use this one to wrap a scikit-learn model and make it behave like a transformer. I find these useful when I want to use something like a KMeans clustering model to generate features for another model. It needs to be fitted in order to train the model it wraps.


```python
class ModelTransformer(TransformerMixin):

    def __init__(self, model):
        self.model = model

    def fit(self, *args, **kwargs):
        self.model.fit(*args, **kwargs)

    def transform(self, X, **transform_params):
        return DataFrame(self.model.predict(X))

    def fit_transform(self, X, y=None, **fit_params):
        self.fit(X, y, **fit_params)
        return self.transform(X)
```

The pipeline treats these objects like any of the built-in transformers and `fit`s them during the training phase, and `transform`s the data using each one when predicting.

# Final Thoughts

While the initial investment is higher, designing my projects this way ensures that I can continue to adapt and improve it without pulling my hair out keeping all the steps straight. It really starts to pay off when you get into hyperparamer tuning, but I'll save that for another post.

If I could add one enhancement to this design, it would be a way to add post-processing steps to the pipeline. I usually end up needing to take a few final steps like setting all negative predictions to `0.0`. The last step in the pipeline is assumed to be the final estimator, and as such the pipeline calls `predict` on it instead of `transform`. Because of this limitation, I end up having to do my post-processing outside of the pipeline:

```python
pipeline.fit(x, y)
predicted = pipeline.predict(test)
predicted[predicted < 0] = 0.0
```

This usually isn't a big problem, but it does make cross-validation a little trickier. Overall, I don't find this very limiting, and I love using pipelines to organize my models.

[1]: http://en.wikipedia.org/wiki/Tf%E2%80%93idf
[2]: http://scikit-learn.org/stable/modules/generated/sklearn.pipeline.Pipeline.html
[3]: http://scikit-learn.org/stable/modules/generated/sklearn.pipeline.FeatureUnion.html
