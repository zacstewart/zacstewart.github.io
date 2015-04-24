# Text Classification

To demonstrate text classification with scikit-learn, we'll build a simple spam
filter. While the filters in production for services like Gmail will obviously
be vastly more sophisticated, the model we'll have by the end of this tutorial
is effective and surprisingly accurate.

Spam filtering is the "hello world" of document classification, but something
to be aware of is that we aren't limited to two classes. The classifier we will
be using supports multi-class classification, which opens up vast opportunities
like author identification, support email routing, etc… However, in this
example we'll just stick to two classes: SPAM and HAM.

We'll use a combination of the [Enron-Spam (in raw form)][enron-spam] data
sets and the [SpamAssassin public corpus][spamassassin]. Both are publicly
available for download.

## Loading Examples

Before we can train a classifier, we need to load our example data in a format
we can feed to our algorithm. scikit-learn typically likes things to be in a
Numpy array-like structure. For a spam classifier, it would be useful to have a
2-dimensional array containing email bodies in one column and a class (also
called a label), i.e. spam or ham, for the document in another.

A good starting place is a generator function that will take a file path,
iterate recursively through all files in said path or its subpaths, and yield
each email body contained therein. This allows us to dump our example data into
directories without meticulously organizing it.

```python
import os

NEWLINE = '\n'
SKIP_FILES = set(['cmds'])

def read_files(path):
  for root, dir_names, file_names in os.walk(path):
    for path in dir_names:
      read_files(os.path.join(root, path))
    for file_name in file_names:
      if file_name not in SKIP_FILES:
        file_path = os.path.join(root, file_name)
        if os.path.isfile(file_path):
          past_header, lines = False, []
          f = open(file_path)
          for line in f:
            if past_header:
              lines.append(line)
            elif line == NEWLINE:
              past_header = True
          f.close()
          yield file_path, NEWLINE.join(lines).decode('cp1252', 'ignore')
```

According to protocol, email headers and bodies are separated by a blank line
(`NEWLINE`), so we simply ignore all lines before that and then yield the rest
of the email. You'll also notice the `decode('cp1252', 'ignore')` bit. This is
necessary to decode the provided dataset into Unicode, which we need to work
with scikit-learn.

Now we need a way to build our dataset from all these email bodies. The Python
library Pandas makes it easy to munge our data into shape as a DataFrame and
then convert it to a Numpy array when we need to send it to our classifier.

```python
from pandas import DataFrame

def build_data_frame(path, classification):
  data_frame = DataFrame({'text': [], 'class': []})
  for file_name, text in read_files(path):
    data_frame = data_frame.append(
        DataFrame({'text': [text], 'class': [classification]}, index=[file_name]))
  return data_frame
```

This function will build us a DataFrame from all the files in `path`. It will
include the body text in one column and the class in another. Each row will be
indexed by the corresponding email's filename. Pandas lets you `append` a
DataFrame to another DataFrame. It's really more of a concatenation than an
append like Python's `list.append()`, so instead of just adding a new row to
the DataFrame, we construct a new one and append it to the prior repeatedly.

Using these two functions, it's really easy for us to build and add to our
dataset:

```python
HAM = 0
SPAM = 1

SOURCES = [
    ('data/spam',         SPAM),
    ('data/easy_ham',     HAM),
    ('data/hard_ham',     HAM),
    ('data/beck-s',       HAM),
    ('data/farmer-d',     HAM),
    ('data/kaminski-v',   HAM),
    ('data/kitchen-l',    HAM),
    ('data/lokay-m',      HAM),
    ('data/williams-w3',  HAM),
    ('data/BG',           SPAM),
    ('data/GP',           SPAM),
    ('data/SH',           SPAM)
    ]

data = DataFrame({'text': [], 'class': []})
for path, classification in SOURCES:
  data = data.append(build_data_frame(path, classification))
  
data = data.reindex(numpy.random.permutation(data.index))
```

As you can see, increasing the size of our training set is just a matter of
dumping a collection of emails into a directory and then adding it to `SOURCES`
with an applicable class. The last thing we do is use DataFrame's `reindex` to
shuffle our whole dataset. Otherwise, we'd have contiguous blocks of examples
from each source. This is important for validating our results later.

Now that the data is in a usable format, let's talk about how to turn raw email
text into useful features.

## Extracting Features

Before we can train an algorithm to classify a document, we have to extract
features from it. In general terms, that means to reduce the mass of
unstructured data into some uniform set of attributes that our algorithm can
learn from. For text classification, that can mean word counts. We produce a
table of each word mentioned in the corpus (that is, the unioned collection of
emails) and its corresponding frequency for each class of email. A contrived
visualization might look like this:

|      | I   | Linux | tomorrow | today | Viagra | Free |
|------|-----|-------|----------|-------|--------|------|
| HAM  | 319 | 619   | 123      | 67    | 0      | 50   |
| SPAM | 233 | 3     | 42       | 432   | 291    | 534  |

The code to do this using scikit-learn's `feature_extraction` module is pretty
minimal. We'll instantiate a `CountVectorizer` and then call its instance method
`fit_transform`, which does two things: it learns the vocabulary of our corpus
and extracts our word count features. This method is an efficient way to do
both steps and for us it does the job, but in some cases you may want to use a
different vocabulary than the one inherent in the raw data. For this reason,
`CountVectorizer` provides `fit` and `transform` methods to do them separately.
Additionally, you can provide a vocabulary in the constructor.

To get the text from our DataFrame, you just access it like a dictionary and it
returns a vector of email bodies, which we convert to a Numpy array.

```python
import numpy
from sklearn.feature_extraction.text import CountVectorizer

count_vectorizer = CountVectorizer()
counts = count_vectorizer.fit_transform(numpy.asarray(data['text']))
```

With these counts as features, we can go to the next steps: training a
classifier and classifying individual emails.

## Classifying Emails

We're going to use a naïve Bayes classifier to learn from the features. A naïve
Bayes classifier applies the Bayes theorem with naïve independence assumptions.
That is, each feature (in this case word counts) is independent from every
other one and each one contributes to the probability that an example belongs
to a particular class. Using our contrive table above, a super spammy word like
"Free" contributes to the probability that an email containing it is spam,
however, a non-spam email could also contain "Free," balanced out with
non-spammy words like "Linux" and "tomorrow."

We instantiate a new `MultinomialNB` and train it by calling `fit`, passing in
our feature vector and target vector (the classes that each example belongs
to). The indices of each vector must be aligned, but luckily Pandas keeps that
straight for us.

```python
from sklearn.naive_bayes import MultinomialNB

classifier = MultinomialNB()
targets = numpy.asarray(data['class'])
classifier.fit(counts, targets)
```

And there we have it: a trained spam classifier. We can try it out by
constructing some examples and predicting on them.

```python
examples = ['Free Viagra call today!', "I'm going to attend the Linux users group tomorrow."]
example_counts = count_vectorizer.transform(examples)
predictions = classifier.predict(example_counts)
predictions # [1, 0]
```

Our predictions vector should be `[1, 0]`, corresponding to the constants we
defined for `SPAM` and `HAM`.

Still, doing each one of those steps one-at-a-time was pretty tedious. We can
package it all up using a construct provided by scikit-learn called a `Pipeline`.

# Pipelining

A pipeline does exactly what it sounds like: connects a series of steps into
one object which you train and then use to make predictions. I've written about
[using scikit-learn pipelines][pipelines] in detail, so I won't redo that here.
In short, we can use a pipeline to merge our feature extraction and
classification into one operation:

```python
from sklearn.pipeline import Pipeline

pipeline = Pipeline([
  ('vectorizer',  CountVectorizer()),
  ('classifier',  MultinomialNB()) ])

pipeline.fit(numpy.asarray(data['text']), numpy.asarray(data['class']))
pipeline.predict(examples) # [1, 0]
```

The first element of each tuple in the pipeline, 'vectorizer', and
'classifier', are arbitrary names. Pipelining simplifies things a lot
when you start tweaking your model to improve your results, and we'll see why
later. First, we need to get some real performance metrics. Classifying two
short, imaginary messages isn't a very rigorous test. We need to
_cross-validate_ with some real emails which we already have labels for, much
like the examples we trained on.

## Cross-Validating

To validate our classifier against unseen data, we can just split our training
set into two parts with a ratio of 2:8 or so. Given that our dataset has been
shuffled, each portion should contain an equal distribution of example types.
We hold out the smaller portion (the cross-validation set), train the
classifier on the larger part, predict on the cross-validation set, and compare
the predictions to the examples' already-known classes. This method works very
well, but it has the disadvantage of your classifier not getting trained and
validated on all examples in the data set.

A more sophisticated method is known as _k-fold cross-validation_. Using this
method, we split the data set into k parts, hold out one, combine the others
and train on them, then validate against the held-out portion. You repeat that
process k times (each _fold_), holding out a different portion each time. Then
you average the score measured for each fold to get a more accurate
estimation of your model's performance.

While the process sounds complicated, scikit-learn makes it really easy. We'll
split our data set into 6 folds and cross-validate on them. scikit-learn's
`KFold` can be used to generate k pairs of index vectors. Each pair contains a
list of indices to select a training subset of the data and a list of indices
to select a validation subset of the data.

```python
from sklearn.cross_validation import KFold

k_fold = KFold(n=len(data), n_folds=6, indices=False)
scores = []
for train_indices, test_indices in k_fold:
  train_text = numpy.asarray(data[train_indices]['text'])
  train_y    = numpy.asarray(data[train_indices]['class'])

  test_text  = numpy.asarray(data[test_indices]['text'])
  test_y     = numpy.asarray(data[test_indices]['class'])

  pipeline.fit(train_text, train_y)
  score = pipeline.score(test_text, test_y)
  scores.append(score)

score = sum(scores) / len(scores)
```

scikit-learn models provide a `score` method, which gives us the mean accuracy
of the model on each fold, which we then average together for a mean accuracy
on the entire set. Using the model we just built and the example data sets
mentioned in the beginning of this tutorial, we get about 90% accuracy. Out of
55,326 examples, we get about 2,454 false spams, and 2,894 false hams. I say
"about" because by shuffling the data as we did, these numbers will vary each
time we run the model.

That's really not bad for a first run. Obviously it's not production-ready even
if we don't consider the scaling issues. Consumers demand accuracy, especially
regarding false spams. Who doesn't hate to lose something important to the spam
filter?

## Improving Results

In order to get better results, there's a few things we can change. We can try
to extract more features from the emails, we can try different kinds of
features, we can tune the parameters of the naïve Bayes classifier, or try
another classifier all together.

One way to get more features is to use n-gram counts instead of just word
counts. So far we've relied upon what's known as "bag of words" features. It's
called that because we simply toss all the words of a document into a "bag" and
count them, disregarding any meaning that could locked up in the _ordering_ of
words.

An n-gram can be thought of as a phrase that is _n_ words long. For example, in
the sentence "Don't tase me, bro" we have the 1-grams, "don't," "tase," "me,"
and "bro." The same sentence also has the 2-grams (or bigrams) "don't tase",
"tase me", and "me bro." We can tell `CountVectorizer` to include any order of
n-grams by giving it a range. For this data set, unigrams and bigrams seem to
work well. 3-grams add a tiny bit more accuracy, but for the computation time
they incur, it's probably not worth the marginal increase.

```python
pipeline = Pipeline([
  ('count_vectorizer',   CountVectorizer(ngram_range=(1, 2))),
  ('classifier',         MultinomialNB()) ])
```

That boosts our model up to almost 93% accuracy. As before, it's a good idea to
keep an eye on how it's doing for individual classes and not just the set as a
whole. Luckily this increase represents an increase for both spam and ham
classification accuracy.

Another way to improve our results is to use different kinds of features.
N-gram counts have the disadvantage of unfairly weighting longer documents. A
six-word spammy message and a five-page, heartfelt letter with six "spammy"
words could potentially receive the same "spamminess" probability. To counter
that, we can use _frequencies_ rather than _occurances_. That is, focusing on
how much of the document is made up of a particular word, instead of how many
times the word appears in the document. This kind of feature set is known as
_term frequencies_.

In addition to converting counts to frequencies, we can reduce noise in our
features by reducing the weight for words that are common across the entire
corpus. For example, words like "and," "the," and "but" probably don't contain
a lot of information about the topic of the document, even though they will
have high counts and frequencies across both ham and spam. To remedy that, we
can use what's known as _inverse document frequency_ or IDF.

Adding another vectorizer to our pipeline will convert the term counts to term
frequencies and apply the IDF transformation:

```python
pipeline = Pipeline([
  ('count_vectorizer',   CountVectorizer(ngram_range=(1, 2))),
  ('tfidf_transformer',  TfidfTransformer()),
  ('classifier',         MultinomialNB()) ])
```

Unfortunately, with this particular data set, using TF-IDF features results in
a slightly more accurate model in the general sense, but it causes it to have
considerably higher rates of false spam classification. That would result in a
larger quantity of legitimate emails being caught in the filter, which in
practice would be less desirable than having to manually delete the occasional
spam.

To wrap up this tutorial, we'll try one more thing: using a different
classifier. The Bernouli naïve Bayes classifier differs in a few ways, but in
our case, the important difference is that it operates on n-gram occurrences
rather than counts. Instead of a numeric vector representing n-gram counts, it
uses a vector a booleans. In general, this model performs better on shorter
documents, so if we wanted to filter forum spam or tweets, it would probably be
the one to use.

We don't have to change any of our feature extraction pipeline (except that
we're removing the `TfidfTransformer` step and just using the `CountVectorizer`
again). BernoulliNB has a `binarize` parameter for setting the threshold for
converting numeric values to booleans. We'll use 0.0, which will convert words
which are not present in a document to `False` and words which are present any
number of times to `True`.

```python
from sklearn.naive_bayes import BernoulliNB

pipeline = Pipeline([
  ('count_vectorizer',   CountVectorizer(ngram_range=(1, 2))),
  ('classifier',         BernoulliNB(binarize=0.0)) ])
```

This model does pretty poorly, but in a different way than the previous models.
It allows a lot more spam to slip through, but there's potential for it to
improve if we could find the right `binarize` threshold.

For anyone keeping count, out of 55,326 emails (21,838 ham, 33,488 spam), our
models have performed this well so far:

| Features            | Classifier    | False spams    | False hams      | General accuracy |
|---------------------|---------------|----------------|-----------------|------------------|
| Bag of words counts | MultinomialNB | 2454 (0.07328) | 2894 (0.12150)  | 0.90334          |
| Bigram counts       | MultinomialNB | 2399 (0.07164) | 1466 (0.06155)  | 0.93014          |
| Bigram frequencies  | MultinomialNB | 2629 (0.07851) | 139 (0.00584)   | 0.94997          |
| Bigram occurrences  | BernoulliNB   | 53 (0.00158)   | 14881 (0.62478) | 0.73007          |

The best solution we've encountered has been to train a `MultinomialNB` using
either bigram counts or frequencies.

Something you should be asking yourself by this time is, "Why all the arbitrary
parameters?" Why did we binarize at a threshold of 0.0? Why unigrams and
bigrams? We were particular in the way we went about evaluating the accuracy of
the models, namely k-folding, yet we didn't really apply the same rigor when we
configured our classifiers. How do we know if we're doing the best we can?

The answer is, those parameters are arbitrary are are very likely _not_ the
optimal configuration. However, considering that our classifier takes several
minutes to train and validate, it would take forever for us to exhaustively
fine-tune, re-run, and test each change we could make.

Another thing that might come to mind is that even though the Bernouli model
performed very poorly, it seemed to have some value in that it got fewer false
spams than any of the others.

Luckily, there are ways to automate the fine-tuning process as well as combine
the predictions of multiple classifiers. Grid search parameter tuning and
multi-model _ensemble learning_ will be explained in a later tutorial. For now,
we've done a pretty good job at classifying some documents. A fun exercise
might be to dump your email archives into the example data and label it
according to the sender and seeing if you can accurately identify the authors.

[enron-spam]: http://www.aueb.gr/users/ion/data/enron-spam/
[spamassassin]: https://spamassassin.apache.org/publiccorpus/
[pipelines]: http://zacstewart.com/2014/08/05/pipelines-of-featureunions-of-pipelines.html
