# For our example we call the implemented flower pollination algorithm
# with a flower count of 175, min value of -5, max value of 5, 
# number of iterations being 300, gamma value of 0.1, lamb value of 1.5,
# and p value of 0.8

import random
import math
import os
import time

def initial_position(flowers, min_values, max_values):
    # initialize a matrix with zero values
    position = [[0] * (len(min_values) + 1) for _ in range(flowers)]

    # iterate through each flower
    for i in range(0, flowers):
        # generate a random position for each x and y coordinate
        for j in range(0, len(min_values)):
            position[i][j] = random.uniform(min_values[j], max_values[j])
        
        # set the last column value as the evaluation of the six hump
        # camel back function at the position
        position[i][-1] = six_hump_camel_back(position[i][0:len(min_values)])
    
    # return the matrix of initial flower positions
    return position

def levy_flight(beta):
    # generate two random numbers 
    r1 = int.from_bytes(os.urandom(8), byteorder = "big") / ((1 << 64) - 1)
    r2 = int.from_bytes(os.urandom(8), byteorder = "big") / ((1 << 64) - 1)
    
    # calculate the sigma numerator 
    sig_num = math.gamma(1 + beta) * math.sin((math.pi * beta) / 2.0)
    
    # calculate the sigma denominator
    sig_den = math.gamma((1 + beta) / 2) * beta * 2**((beta - 1) / 2)
    
    # calculate the sigma value
    sigma = (sig_num / sig_den)**(1 / beta)
    
    # calculate the levy step length and return the value
    levy = (0.01 * r1 * sigma) / (abs(r2)**(1 / beta))
    return levy

def clip(num, min_value, max_value):
    return max(min(num, max_value), min_value)

def pollination_global(position, best_global, flower, gama, lamb, 
                       min_values, max_values):
    # create a copy of the best global position
    x = list(best_global)
    
    # update the x and y coordinates of the position using global pollination
    for j in range(0, len(min_values)):
        x[j] = clip((position[flower][j]  + gama * levy_flight(lamb) * 
                     (position[flower][j] - best_global[j])), 
                    min_values[j], max_values[j])
    
    # set the last column value as the evaluation of the six hump
    # camel back function at the position
    x[-1]  = six_hump_camel_back(x[0:len(min_values)])
    
    # return the new position
    return x

def pollination_local(position, best_global, flower, nb_flower_1, nb_flower_2, 
                      min_values, max_values):
    # create a copy of the best global position
    x = list(best_global)
    
    # update the x and y coordinates of the position using local pollination
    for j in range(0, len(min_values)):
        # generate a random number 
        r = int.from_bytes(os.urandom(8), byteorder = "big") / ((1 << 64) - 1)
        x[j] = clip((position[flower][j]  + r * 
                     (position[nb_flower_1][j] - position[nb_flower_2][j])), 
                    min_values[j], max_values[j])
    
    # set the last column value as the evaluation of the six hump
    # camel back function at the position
    x[-1] = six_hump_camel_back(x[0:len(min_values)])
    
    # return the new position
    return x

def fpa(flowers, min_values, max_values, iterations, gama, lamb, p):
    # record the start time of the algorithm
    start = time.time()
    
    # initialize the positions of the flowers
    position = initial_position(flowers, min_values, max_values)
    
    # find the best global position from the initial flowers
    best_global = sorted(position, key=lambda x: x[-1])[0]
    
    # create a copy of the best global position
    x = list(best_global)
    
    # iterate through the set amount of iterations
    for count in range(iterations):
        # print the current iteration and the best position found
        print("Iteration = ", count, " f(x) = ", best_global[-1])
        
        # iterate through each flower
        for i in range(0, len(position)):
            # choose two random flowers for local pollination
            nb_flower_1 = int(random.random() * len(position))
            nb_flower_2 = int(random.random() * len(position))
            
            # ensure that the two flowers are not the same
            while nb_flower_1 == nb_flower_2:
                nb_flower_1 = int(random.random() * len(position))
            
            # generate a random number between 0 and 1
            r = int.from_bytes(os.urandom(8), byteorder = "big") / ((1 << 64) - 1)
            
            # if the random number is less than p then perform global pollination
            # otherwise perform local pollination
            if (r < p):
                x = pollination_global(position, best_global, i, gama, lamb, 
                                       min_values, max_values)
            else:
                x = pollination_local(position, best_global, i, nb_flower_1, 
                                      nb_flower_2, min_values, max_values)
            
            # if the new position results in a better solution, then 
            # update the current position
            if (x[-1] <= position[i][-1]):
                for j in range(0, len(x)):
                    position[i][j] = x[j]
            
            # if the best position has been improved then update it
            value = sorted(position, key=lambda x: x[-1])[0]
            if (best_global[-1] > value[-1]):
                best_global = list(value)
    
    # record the end time of the algorithm
    end = time.time()
    return best_global

def six_hump_camel_back(variables_values):
    return 4 * variables_values[0]**2 - 2.1 * variables_values[0]**4 + (1/3) * variables_values[0]**6 + \
           variables_values[0] * variables_values[1] - 4 * variables_values[1]**2 + 4 * variables_values[1]**4

best_solution = fpa(175, [-5,-5], [5,5], 300, 0.1, 1.5, 0.8)
