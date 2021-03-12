-- show dataset
select * from titanic_data
order by passengerid;
/

-- show survive-death number
select survived, count(*) from titanic_data group by survived;
/

-- separate train data / test data
CREATE OR REPLACE VIEW TRAIN_DATA_TITANIC AS SELECT * FROM titanic_data SAMPLE (70) SEED (1);
/
CREATE OR REPLACE VIEW TEST_DATA_TITANIC AS SELECT * FROM titanic_data MINUS SELECT * FROM TRAIN_DATA_TITANIC;
/

-- create linear regression model
BEGIN DBMS_DATA_MINING.DROP_MODEL('LINEAR_REGRESSION');
EXCEPTION WHEN OTHERS THEN NULL; END;
/

DECLARE
    v_setlst DBMS_DATA_MINING.SETTING_LIST;
    
BEGIN
    v_setlst('PREP_AUTO') := 'ON';
    v_setlst('ALGO_NAME') := 'ALGO_GENERALIZED_LINEAR_MODEL';
    v_setlst('GLMS_DIAGNOSTICS_TABLE_NAME') := 'GLMR_SH_SAMPLE_DIAG_LINEAR';
    v_setlst('GLMS_RIDGE_REGRESSION') := 'GLMS_RIDGE_REG_ENABLE';
    
    
    DBMS_DATA_MINING.CREATE_MODEL2(
        MODEL_NAME          => 'LINEAR_REGRESSION',
        MINING_FUNCTION     => 'REGRESSION',
        DATA_QUERY          => 'SELECT * FROM TRAIN_DATA_TITANIC',
        SET_LIST            => v_setlst,
        CASE_ID_COLUMN_NAME => 'PASSENGERID',
        TARGET_COLUMN_NAME  => 'SURVIVED'
    );
END;
/

-- create linear regression view
CREATE OR REPLACE VIEW survival_prediction_linear AS
    SELECT passengerid, 
        round(PREDICTION(LINEAR_REGRESSION USING *)) PREDICTION_SURVIVED, 
        SURVIVED ACTUAL_SURVIVED
    FROM TEST_DATA_TITANIC
    ORDER BY passengerid;
/

-- Linear Regression prediction
select * from survival_prediction_linear;
/

-- create logistic regression model
BEGIN DBMS_DATA_MINING.DROP_MODEL('LOGISTIC_REGRESSION');
EXCEPTION WHEN OTHERS THEN NULL; END;
/

DECLARE
    v_setlst DBMS_DATA_MINING.SETTING_LIST;
    
BEGIN
    v_setlst('PREP_AUTO') := 'ON';
    v_setlst('ALGO_NAME') := 'ALGO_GENERALIZED_LINEAR_MODEL';
    v_setlst('GLMS_DIAGNOSTICS_TABLE_NAME') := 'GLMR_SH_SAMPLE_DIAG_LOGISTIC';
    v_setlst('GLMS_RIDGE_REGRESSION') := 'GLMS_RIDGE_REG_ENABLE';
    
    
    DBMS_DATA_MINING.CREATE_MODEL2(
        MODEL_NAME          => 'LOGISTIC_REGRESSION',
        MINING_FUNCTION     => 'CLASSIFICATION',
        DATA_QUERY          => 'SELECT * FROM TRAIN_DATA_TITANIC',
        SET_LIST            => v_setlst,
        CASE_ID_COLUMN_NAME => 'PASSENGERID',
        TARGET_COLUMN_NAME  => 'SURVIVED'
    );
END;
/

-- create logistic regression view
CREATE OR REPLACE VIEW survival_prediction_logistic AS
    SELECT passengerid, 
        PREDICTION(LOGISTIC_REGRESSION USING *) PREDICTION_SURVIVED, 
        SURVIVED ACTUAL_SURVIVED
    FROM TEST_DATA_TITANIC
    ORDER BY passengerid;
/

-- logistic regression prediction
select * from survival_prediction_logistic;
/

-- support vector machines model
BEGIN DBMS_DATA_MINING.DROP_MODEL('SUPPORT_VECTOR_MACHINES');
EXCEPTION WHEN OTHERS THEN NULL; END;
/

DECLARE
    v_setlst DBMS_DATA_MINING.SETTING_LIST;
    
BEGIN
    v_setlst('PREP_AUTO') := 'ON';
    v_setlst('ALGO_NAME') := 'ALGO_SUPPORT_VECTOR_MACHINES';
    
    
    DBMS_DATA_MINING.CREATE_MODEL2(
        MODEL_NAME          => 'SUPPORT_VECTOR_MACHINES',
        MINING_FUNCTION     => 'REGRESSION',
        DATA_QUERY          => 'SELECT * FROM TRAIN_DATA_TITANIC',
        SET_LIST            => v_setlst,
        CASE_ID_COLUMN_NAME => 'PASSENGERID',
        TARGET_COLUMN_NAME  => 'SURVIVED'
    );
END;
/

-- support vector machines view
CREATE OR REPLACE VIEW survival_prediction_vector AS
    SELECT passengerid, 
        round(PREDICTION(SUPPORT_VECTOR_MACHINES USING *)) PREDICTION_SURVIVED, 
        SURVIVED ACTUAL_SURVIVED
    FROM TEST_DATA_TITANIC
    ORDER BY passengerid;
/

-- Support Vector Machines prediction
select * from survival_prediction_vector;
/

-- decision tree model
BEGIN DBMS_DATA_MINING.DROP_MODEL('DECISION_TREE');
EXCEPTION WHEN OTHERS THEN NULL; END;
/

DECLARE
    v_setlst DBMS_DATA_MINING.SETTING_LIST;
    
BEGIN
    v_setlst('PREP_AUTO') := 'ON';
    v_setlst('ALGO_NAME') := 'ALGO_DECISION_TREE';
    v_setlst('TREE_IMPURITY_METRIC') := 'TREE_IMPURITY_GINI';
    v_setlst('TREE_TERM_MAX_DEPTH') := '2';
    
    
    DBMS_DATA_MINING.CREATE_MODEL2(
        MODEL_NAME          => 'DECISION_TREE',
        MINING_FUNCTION     => 'CLASSIFICATION',
        DATA_QUERY          => 'SELECT * FROM TRAIN_DATA_TITANIC',
        SET_LIST            => v_setlst,
        CASE_ID_COLUMN_NAME => 'PASSENGERID',
        TARGET_COLUMN_NAME  => 'SURVIVED'
    );
END;
/

-- decision tree view
CREATE OR REPLACE VIEW survival_prediction_decision AS
    SELECT passengerid, 
        PREDICTION(DECISION_TREE USING *) PREDICTION_SURVIVED, 
        SURVIVED ACTUAL_SURVIVED
    FROM TEST_DATA_TITANIC
    ORDER BY passengerid;
/

-- Decision Tree prediction
select * from survival_prediction_decision;
/

-- Naive Bayes model
BEGIN DBMS_DATA_MINING.DROP_MODEL('NAIVE_BAYES');
EXCEPTION WHEN OTHERS THEN NULL; END;
/

DECLARE
    v_setlst DBMS_DATA_MINING.SETTING_LIST;
    
BEGIN
    v_setlst('PREP_AUTO') := 'ON';
    v_setlst('ALGO_NAME') := 'ALGO_NAIVE_BAYES';
    
    
    DBMS_DATA_MINING.CREATE_MODEL2(
        MODEL_NAME          => 'NAIVE_BAYES',
        MINING_FUNCTION     => 'CLASSIFICATION',
        DATA_QUERY          => 'SELECT * FROM TRAIN_DATA_TITANIC',
        SET_LIST            => v_setlst,
        CASE_ID_COLUMN_NAME => 'PASSENGERID',
        TARGET_COLUMN_NAME  => 'SURVIVED'
    );
END;
/

-- naive bayes view
CREATE OR REPLACE VIEW survival_prediction_naive AS
    SELECT passengerid, 
        PREDICTION(NAIVE_BAYES USING *) PREDICTION_SURVIVED, 
        SURVIVED ACTUAL_SURVIVED
    FROM TEST_DATA_TITANIC
    ORDER BY passengerid;
/

-- Naive Bayes prediction
select * from survival_prediction_naive;
/

-- Final prediction view creation
CREATE OR REPLACE VIEW survival_prediction AS
    SELECT A.PASSENGERID, 
        A.ACTUAL_SURVIVED ACTUAL, 
        A.PREDICTION_SURVIVED LINEAR_REGRESSION,
        B.PREDICTION_SURVIVED LOGISTIC_REGRESSION,
        C.PREDICTION_SURVIVED SUPPORT_VECTOR_MACHINES,
        D.PREDICTION_SURVIVED DECISION_TREE,
        E.PREDICTION_SURVIVED NAIVE_BAYES
    FROM survival_prediction_linear A, 
        survival_prediction_logistic B, 
        survival_prediction_support C, 
        survival_prediction_decision D,
        survival_prediction_naive E
    WHERE A.PASSENGERID = B.PASSENGERID AND
          A.PASSENGERID = C.PASSENGERID AND
          A.PASSENGERID = D.PASSENGERID AND
          A.PASSENGERID = E.PASSENGERID;
/

-- show final prediction
SELECT * FROM survival_prediction;
/

-- create update_accuracy function
CREATE OR REPLACE FUNCTION update_accuracy(accuracy_linear NUMBER, accuracy_logistic NUMBER, accuracy_vector NUMBER, accuracy_decision NUMBER, accuracy_naive NUMBER)
RETURN NUMBER
IS
BEGIN
    --CREATE TABLE ALGO_ACCURACY (
    --    algo_name varchar2(200),
    --    accuracy number
    --);

    UPDATE ALGO_ACCURACY SET accuracy = accuracy_linear   WHERE algo_name = 'LINEAR_REGRESSION';
    UPDATE ALGO_ACCURACY SET accuracy = accuracy_logistic WHERE algo_name = 'LOGISTIC_REGRESSION';
    UPDATE ALGO_ACCURACY SET accuracy = accuracy_vector   WHERE algo_name = 'SUPPORT_VECTOR_MACHINES';
    UPDATE ALGO_ACCURACY SET accuracy = accuracy_decision WHERE algo_name = 'DECISION_TREE';
    UPDATE ALGO_ACCURACY SET accuracy = accuracy_naive    WHERE algo_name = 'NAIVE_BAYES';
    RETURN (1);
    
EXCEPTION 
    WHEN OTHERS THEN
        RETURN(0);
END;
/

-- create calculate_accuracy function
CREATE OR REPLACE FUNCTION calculate_accuracy(total_row NUMBER, correct_row NUMBER)
RETURN NUMBER
IS
    accuracy NUMBER;
BEGIN
    accuracy := round(correct_row / total_row * 100);
    RETURN (ACCURACY);
EXCEPTION
    WHEN OTHERS THEN
        RETURN (0);
END;
/

-- calculate accuracy for the algorithms
DECLARE 
    total_row               number;
    correct_row_linear      number;
    correct_row_logistic    number;
    correct_row_vector      number;
    correct_row_decision    number;
    correct_row_naive       number;
    accuracy_linear         number;
    accuracy_logistic       number;
    accuracy_vector         number;
    accuracy_decision       number;
    accuracy_naive          number;
    is_updated              number;
BEGIN
    SELECT COUNT(*) INTO total_row
    FROM survival_prediction;
    
    -- LINEAR REGRESSION
    select count(*) into correct_row_linear
    from survival_prediction a
    where a.ACTUAL = a.LINEAR_REGRESSION;
    
    accuracy_linear := calculate_accuracy(total_row, correct_row_linear);
    
    -- LOGISTIC REGRESSION
    select count(*) into correct_row_logistic
    from survival_prediction a
    where a.ACTUAL = a.LOGISTIC_REGRESSION;
    
    accuracy_logistic := calculate_accuracy(total_row, correct_row_logistic);
    
    -- SUPPORT VECTOR MACHINES
    select count(*) into correct_row_vector
    from survival_prediction a
    where a.ACTUAL = a.SUPPORT_VECTOR_MACHINES;
    
    accuracy_vector := calculate_accuracy(total_row, correct_row_vector);
    
    -- DECISION TREE
    select count(*) into correct_row_decision
    from survival_prediction a
    where a.ACTUAL = a.DECISION_TREE;
    
    accuracy_decision := calculate_accuracy(total_row, correct_row_decision);
    
    -- NAIVE BAYES
    select count(*) into correct_row_naive
    from survival_prediction a
    where a.ACTUAL = a.NAIVE_BAYES;
    
    accuracy_naive := calculate_accuracy(total_row, correct_row_naive);
    
    
    -- UPDATE ACCURACY TABLE IN FUNCTION
    is_updated := update_accuracy(accuracy_linear, accuracy_logistic, accuracy_vector, accuracy_decision, accuracy_naive);
    
    IF is_updated = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR UPDATING ACCURACY');
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('NO DATA FOUND !!');
    WHEN TOO_MANY_ROWS THEN
        dbms_output.put_line('TOO MANY ROWS !!');
    WHEN OTHERS THEN
        dbms_output.put_line('Execution Error !!');
END;
/

-- show algorithms' accuracy
select * from ALGO_ACCURACY;
/