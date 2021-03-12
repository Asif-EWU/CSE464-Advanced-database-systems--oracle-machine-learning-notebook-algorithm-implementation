SET VERIFY OFF;
SET SERVEROUTPUT ON;

-- 1
select * from titanic_data
order by passengerid;
/

-- 2
CREATE OR REPLACE VIEW TRAIN_DATA_TITANIC AS SELECT * FROM titanic_data SAMPLE (70) SEED (1);
CREATE OR REPLACE VIEW TEST_DATA_TITANIC AS SELECT * FROM titanic_data MINUS SELECT * FROM TRAIN_DATA_TITANIC;
/

-- 3
BEGIN DBMS_DATA_MINING.DROP_MODEL('LOGISTIC_REGRESSION');
EXCEPTION 
    WHEN OTHERS THEN 
        NULL; 
END;
/

-- 4
DECLARE
    v_setlst DBMS_DATA_MINING.SETTING_LIST;
    
BEGIN
    v_setlst('PREP_AUTO') := 'ON';
    v_setlst('ALGO_NAME') := 'ALGO_DECISION_TREE';
    v_setlst('GLMS_DIAGNOSTICS_TABLE_NAME') := 'GLMR_SH_SAMPLE_DIAG_DECISION';
    v_setlst('GLMS_RIDGE_REGRESSION') := 'GLMS_RIDGE_REG_ENABLE';
    v_setlst('TREE_TERM_MAX_DEPTH') := '2';
    
    
    DBMS_DATA_MINING.CREATE_MODEL2(
        MODEL_NAME          => 'DECISION_TREE',
        MINING_FUNCTION     => 'CLASSIFICATION',
        DATA_QUERY          => 'SELECT * FROM TRAIN_DATA_TITANIC',
        SET_LIST            => v_setlst,
        CASE_ID_COLUMN_NAME => 'PASSENGERID',
        TARGET_COLUMN_NAME  => 'SURVIVED');
END;
/

-- 5
CREATE OR REPLACE VIEW survival_prediction_decision AS
    SELECT passengerid, PREDICTION(DECISION_TREE USING *) PREDICTION_SURVIVED, SURVIVED ACTUAL_SURVIVED
    FROM TEST_DATA_TITANIC
    ORDER BY passengerid;
/

-- 6
DECLARE 
    total_row number;
    correct_row number;
    accuracy number;
BEGIN
    SELECT COUNT(*) INTO total_row
    FROM survival_prediction_decision;
    
    select count(*) into correct_row
    from survival_prediction_decision a
    where a.prediction_survived = a.actual_survived;
    
    accuracy := round(correct_row / total_row * 100);
    dbms_output.put_line('Algorithm Accuracy = ' || accuracy || '%');
END;
/

