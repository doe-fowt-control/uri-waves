import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn import preprocessing

def make_regression(data, color, plot = False):
    """
    Uses sklearn linear regression tool to make linear models for each wave gauge
        data - pandas DataFrame with specific column naming convention
        color - color of wave gauge/pot unit
        plot - decides whether or not to make a plot of the result
    Returns:
        Linear regression model

    """
    # values converts it into a numpy array
    # -1 means that calculate the dimension of rows, but have 1 column

    X = data.loc[:, color + "_g"].values.reshape(-1, 1) # voltage as input
    Y = data.loc[:, color + "_p"].values.reshape(-1, 1) * 10 # potentiometer "height" as output
    linear_regressor = LinearRegression()
    model = linear_regressor.fit(X, Y)

    if plot:
        plt.scatter(X, Y, color = 'k', alpha = 0.1)
        plt.plot(X, model.predict(X), color = color, label = color)
        plt.ylabel("Potentiometer (cm)")
        plt.xlabel("Wave gauge (V)")
        plt.title("Linearization curve")
        plt.legend()
        plt.show()
    return model

def model_func(model):
    '''
    extract line equation from sklearn linear regression
    '''
    # Slope of line is rise / run, run = 1
    b = model.predict([[0]]).tolist()[0][0]
    m = model.predict([[1]]).tolist()[0][0] - b

    # Return line with no intercept - assumes data is centered on mean
    return lambda x: m * x
