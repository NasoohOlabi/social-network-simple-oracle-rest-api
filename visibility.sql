CREATE OR REPLACE FUNCTION visibility(visibility_number NUMBER(4)) RETURN VARCHAR2
AS
    begin
        CASE visibility_number
            WHEN 1 THEN
                return 'public' ;
            WHEN 2 THEN
                return 'only me' ;
            WHEN 3 THEN
                return 'friends only' ;
            WHEN 4 THEN
                return 'friends except' ;
            when 5 then
                return 'only list' ;
            ELSE
                return 'public';
        END CASE;
    end;
CREATE OR REPLACE FUNCTION visibility(visibility_name VARCHAR2)
RETURN NUMBER
AS
BEGIN
    CASE visibility_name
        WHEN 'public' THEN
            return 1 ;
        WHEN 'only me' THEN
            return 2 ;
        WHEN 'friends only' THEN
            return 3 ;
        WHEN 'friends except' THEN
            return 4 ;
        WHEN 'only list' THEN
            return 5 ;
        ELSE
            return 1;
    END CASE;
END;

