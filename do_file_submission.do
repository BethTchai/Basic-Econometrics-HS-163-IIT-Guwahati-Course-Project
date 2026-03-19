*Loading data:

use "R:\HSS\Final submission\raw_file.dta"

*Data Cleaning:

describe
drop rowid statelgdcode country yearcode

*Check for missing values:
misstable summarize

*Removing NULL values:
drop if missing(numberoffactories) | missing(fixedcapital) | missing(workingcapital)

*Some entries have decimal values in the columns (detailed explanation in the report). The following loop is used to round all those values to integers.
foreach var of varlist * {
    capture confirm numeric variable `var'
    if !_rc {
        replace `var' = round(`var')
    }
}

*Workflow and execution

*Noteworthy observation!:
correlate numberofworkers personsengagedinfactories
regress valueofgrossoutput numberofworkers
regress valueofgrossoutput personsengagedinfactories
regress valueofgrossoutput numberofworkers personsengagedinfactories
*We see that the two variables are highly correlated (>0.99) but their coefficients obtained on regression are of opposite signs.
*Explanation of the result mentioned in the report.
*The following plot confirms that both variables are highly correlated:
twoway (scatter valueofgrossoutput numberofworkers, mcolor(blue)) (scatter valueofgrossoutput personsengagedinfactories, mcolor(red)), legend(label(1 "Number of Workers") label(2 "Persons Engaged")) xtitle("Labor Input") ytitle("Value of Gross Output") title("Output vs. Labor Input Measures")

*To begin, we first try to check how the variables are actually correlated to each other: 
correlate numberoffactories fixedcapital workingcapital physicalworkingcapital productivecapital investedcapital numberofworkers personsengagedinfactories totalemoluments totalinputs valueofgrossoutput netvalueadded grossvalueadded netfixedcapitalformation grossfixedcapitalformation grosscapitalformation

*To be sure, we find the value of VIF score when we include all the variables: 
regress valueofgrossoutput numberoffactories fixedcapital workingcapital physicalworkingcapital productivecapital investedcapital numberofworkers personsengagedinfactories totalemoluments totalinputs netvalueadded grossvalueadded netfixedcapitalformation grossfixedcapitalformation grosscapitalformation
vif
*Clearly, the variables have high correlation (a lot of values being > 0.9). Thus we study the variables through an economic perspective and reach the following 6 variables:

regress valueofgrossoutput numberoffactories personsengagedinfactories totalemoluments totalinputs netfixedcapitalformation grosscapitalformation
vif
*The VIF score is still high for a few variables.
*Further study allows us to drop two more variables (explained in the report).

*So our final regression model is as follows: 
regress valueofgrossoutput personsengagedinfactories totalemoluments totalinputs grosscapitalformation
vif
*All VIF scores are less than 10 and the average VIF score is 5.90 with an R2 score of 0.9670. This is a good result.

*Next we check for heteroscedasticity: 

regress valueofgrossoutput personsengagedinfactories totalinputs totalemoluments grosscapitalformation
predict residuals, residuals
predict fitted, xb
twoway (scatter residuals fitted, sort)
hettest
*We add 'robust' to our regression to take into account the heteroscedasticity in our data:
regress valueofgrossoutput personsengagedinfactories totalinputs totalemoluments grosscapitalformation, robust

*Now we move to testing serial correlation:
regress valueofgrossoutput personsengagedinfactories totalinputs totalemoluments grosscapitalformation, cluster(state)

*Finally, we calculate the analytics of our target variable against each independent variable: 
sum personsengagedinfactories totalinputs totalemoluments grosscapitalformation valueofgrossoutput, detail

*The results of the above analysis are presented in the report.
