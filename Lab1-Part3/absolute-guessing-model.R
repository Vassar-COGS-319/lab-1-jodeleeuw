#### Setting up the data ####

# This section of the code will create a data frame that describes
# each trial in the experiment. The data frame will have two columns:
#
# stimulus - The ordinal value of the stimulus on the current trial
# last.stimulus - The ordinal value of the stimulus on the last trial
#
# The order of trials is generated in a way that avoids repeats of the
# same stimulus on neighboring trials.

# Parameters to control trial generation
n.trials <- 200 # How many trials for each stimulus?
n.stimuli <- 9 # How many different stimuli?

# Create a random order of trials, with no neighboring repeats.
trials <- sample(1:n.stimuli)
for(i in 2:n.trials){
  next.order <- sample(1:n.stimuli)
  while(next.order[1] == trials[length(trials)]){
    next.order <- sample(1:n.stimuli)
  }
  trials <- c(trials, next.order)
}

# Create the array that describes the value of the last trial
# Use NA for the first trial, to represent no previous information.
last.trial <- c(NA, trials[1:(length(trials)-1)])

# Create the data frame
trial.data <- data.frame(stimulus=trials, last.stimulus=last.trial)

#### Model of responses ####

# Your work starts here. Implement the model described in the readme
# file. You should add a new column to trial.data that indicates whether the
# model guessed correctly (TRUE) or incorrectly (FALSE).

# You may want to start by adding a column to indicate what stimulus the model
# guessed. Then you can create a fourth column to indicate whether the guess
# was correct.

# Don't forget about the better.sample function that you wrote in the tutorial file!

trial.data$guess <- mapply(function(current.stimulus, last.stimulus){
  if(is.na(last.stimulus)){
    return(sample(1:n.stimuli, 1))
  }
  if(current.stimulus > last.stimulus){
    low <- last.stimulus + 1
    high <- n.stimuli
  }
  if(current.stimulus < last.stimulus){
    low <- 1
    high <- last.stimulus - 1
  }
  guess <- better.sample(low:high, 1)
  return(guess)
}, trial.data$stimulus, trial.data$last.stimulus)


trial.data$correct <- trial.data$stimulus == trial.data$guess

#### Aggregate the data ####

# Now that you have a model that can generate a response for every trial, you need
# to group the data and find the proportion of trials that the model answered correctly
# for each value of the stimulus column. Then you can compare the data your model generated
# to the data generated in the Neath and Brown experiment.

# This is where you will need to use the dplyr summarize function. Generate a new data frame
# that has the proportion of correct responses for each value of stimulus. (Note that the proportion
# correct is equivalent to taking the mean of the correct column if you code incorrect responses as 0
# and correct responses as 1).

library(dplyr)
summarized.data <- trial.data %>% group_by(stimulus) %>% summarize(mean = mean(correct))

#### Plot the results ####

# Plot the curve with stimulus on the X axis and proportion of correct
# responses on the Y axis.

# Remeber that you can extract a column of data with the $ operator, so something like:
# plot(data$stimulus, data$proportion.correct) should get you close to where you want to be.

plot(summarized.data$stimulus, summarized.data$mean, type="l")

#### Short answer questions (reply using a comment below each number)

# 1. Why does the model's output change slightly each time you run it?

# The list of trials and the guesses are both randomly generated.

# 2. Try increasing and decreasing the number of trials per stimulus. How does
#    this affect the stability of the model's predictions from run to run?
#    Explain why this happens.

# With more samples per stimulus, the effects of randomness average out. For
# example, with only 5 trials per stimulus type it might happen to be the case that
# stimulus 1 is always after stimulus 9, and the accuracy for 1 would be very low.
# With more trials, the probability of this happening drops and the behavior
# of the model stabilizes.

# 3. Explain why the stimuli at the ends have a higher proportion correct than
#    those in the middle under this model.

# Stimuli at the edges benefit from trials where there are relatively few
# options to guess. For example, when stimulus 7 comes before stimulus 9, there
# is a 50% chance of getting the correct answer. For stimulus 5, the best case is
# when the preceeding stimulus is 4 or 6. Even in those cases, the chance of a
# correct guess is only 20%.

# 4. Compare the model's accuracy to the data from Neath and Brown (2005). What
#    is the major difference? What does this suggest about the guessing model?

# The overall accuracy is much higher in the real experiment. This suggests that
# absolute guessing isn't the whole story. Some other addition is needed to get the
# overall accuracy up. One possibility would be to not randomly guess with equal
# probability. Maybe people can detect small vs. large relative changes.