libname HW4 'C:\Users\mmb190001\Hw4';
run;

/*1*/

/*create a new dataset with variable*/
data store;
set HW4.heinzhunts;
LogPriceRatio = log(PriceHeinz/PriceHunts);
run;
/* interaction Effect*/
data store;
set store;
DisplFeatHeinz = DisplHeinz*FeatHeinz;
DisplFeatHunts = DisplHunts*FeatHunts;
run;

/*2*/ 

/*Create Test and training data set*/ 

proc surveyselect data=store out=store_sampled outall samprate=0.8 seed=10;
run;
data store_training store_test;
 set store_sampled;
 if selected then output store_training; 
 else output store_test;
run;

/*3*/

/* Logistic Regression */
ods graphics on;
proc logistic data=store_sampled;
logit: model Heinz (event='1') = LogPriceRatio DisplHeinz FeatHeinz DisplHunts FeatHunts DisplFeatHeinz DisplFeatHunts / clodds= wald orpvalue;
weight selected;
title 'Logit';
run;

/*5*/
data calc;
predicted_1= 3.2142-6.0112*.3 -.5529-1.1403-0.9322;
prob1=exp(predicted_1)/(1+exp(predicted_1));
predicted_2= 3.2142-6.0112*.4 -.5529-1.1403-0.9322;
prob2=exp(predicted_2)/(1+exp(predicted_2));
diff= prob1-prob2;
run;


/*6*/

/*Create the roc table for the Score Data*/

proc logistic data=store_training outmodel=outmodel1 ;
 logit: model Heinz (event='1') = LogPriceRatio DisplHeinz FeatHeinz DisplHunts FeatHunts DisplFeatHeinz DisplFeatHunts;
 title 'ROC table';
run;

proc logistic inmodel=outmodel1;
 score data=store_test outroc=store_logit_roc;
 title 'Score Data';
run;

/*calculating total cost of misclassification*/
data logit_roc_cost;
set store_logit_roc;
False_positive_cost=0.25*_FALPOS_; /*False positive cost is the cost of identifying a hunts customer as heinz and failing to send a coupon*/
False_negative_cost=1*_FALNEG_;/* False negative cost is the cost of identifying a heinz customer as hunts and sending him a coupon*/
Total_cost=False_positive_cost+False_negative_cost;
run;
