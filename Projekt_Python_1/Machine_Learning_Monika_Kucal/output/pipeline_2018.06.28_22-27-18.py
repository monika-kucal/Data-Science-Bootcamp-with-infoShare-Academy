import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline, make_union
from sklearn.svm import LinearSVR
from tpot.builtins import StackingEstimator
from sklearn.preprocessing import FunctionTransformer
from copy import copy

# NOTE: Make sure that the class is labeled 'target' in the data file
tpot_data = pd.read_csv('PATH/TO/DATA/FILE', sep='COLUMN_SEPARATOR', dtype=np.float64)
features = tpot_data.drop('target', axis=1).values
training_features, testing_features, training_target, testing_target = \
            train_test_split(features, tpot_data['target'].values, random_state=42)

# Score on the training set was:-1300.868009519682
exported_pipeline = make_pipeline(
    make_union(
        StackingEstimator(estimator=make_pipeline(
            make_union(
                FunctionTransformer(copy),
                FunctionTransformer(copy)
            ),
            StackingEstimator(estimator=RandomForestRegressor(bootstrap=True, criterion="mse", max_features=0.55, min_samples_leaf=3, min_samples_split=10, n_estimators=10)),
            StackingEstimator(estimator=LinearSVR(C=15.0, dual=False, epsilon=0.001, loss="squared_epsilon_insensitive", tol=0.1)),
            RandomForestRegressor(bootstrap=True, criterion="mse", max_features=0.55, min_samples_leaf=3, min_samples_split=11, n_estimators=10)
        )),
        FunctionTransformer(copy)
    ),
    RandomForestRegressor(bootstrap=True, criterion="mae", max_features=0.45, min_samples_leaf=16, min_samples_split=9, n_estimators=10)
)

exported_pipeline.fit(training_features, training_target)
results = exported_pipeline.predict(testing_features)
