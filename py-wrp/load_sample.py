if __name__ == "__main__":
    import numpy as np
    from numpy import genfromtxt
    my_data = genfromtxt('bufferValues.csv', delimiter=',')
    # my_data = my_data[1:,:]
    print((my_data))
