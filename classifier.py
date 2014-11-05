import os
import numpy
from pandas import DataFrame
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.cross_validation import KFold

NEWLINE = '\n'

HAM = 0
SPAM = 1

SOURCES = [
    ('data/spam',        SPAM),
    ('data/easy_ham',    HAM),
    ('data/hard_ham',    HAM),
    ('data/beck-s',      HAM),
    ('data/farmer-d',    HAM),
    ('data/kaminski-v',  HAM),
    ('data/kitchen-l',   HAM),
    ('data/lokay-m',     HAM),
    ('data/williams-w3', HAM),
    ('data/BG',          SPAM),
    ('data/GP',          SPAM),
    ('data/SH',          SPAM)
    ]

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
                    content = NEWLINE.join(lines).decode('cp1252', 'ignore')
                    yield file_path, content


def build_data_frame(path, classification):
    data_frame = DataFrame({'text': [], 'class': []})
    for file_name, text in read_files(path):
        data_frame = data_frame.append(
            DataFrame(
                {'text': [text], 'class': [classification]},
                index=[file_name]))
    return data_frame

data = DataFrame({'text': [], 'class': []})
for path, classification in SOURCES:
    data = data.append(build_data_frame(path, classification))

data = data.reindex(numpy.random.permutation(data.index))

pipeline = Pipeline([
    ('count_vectorizer', CountVectorizer(ngram_range=(1, 2))),
    ('classifier',       MultinomialNB(binarize=0.0))])

k_fold = KFold(n=len(data), n_folds=6, indices=False)
scores, false_positives, false_negatives = [], 0, 0
for train_indices, test_indices in k_fold:
    train_text = numpy.asarray(data[train_indices]['text'])
    train_y = numpy.asarray(data[train_indices]['class'])

    test_text = numpy.asarray(data[test_indices]['text'])
    test_y = numpy.asarray(data[test_indices]['class'])

    pipeline.fit(train_text, train_y)
    predictions = pipeline.predict(test_text)

    incorrect_indices = (predictions != test_y)

    false_positives += sum(predictions[incorrect_indices])
    false_negatives += sum(test_y[incorrect_indices])

    score = pipeline.score(test_text, test_y)
    scores.append(score)

print 'Total emails classified: ' + str(len(data))
print 'Score: ' + str(sum(scores)/len(scores))
print 'False positives: ' + str(false_positives)
print 'False negatives: ' + str(false_negatives)
