-- --------------------------------  PROJECT 1  --------------------------------------------

-- FUNCTION: microrest.hello_world()

-- DROP FUNCTION IF EXISTS microrest.hello_world();

CREATE OR REPLACE FUNCTION microrest.hello_world()
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    vhola character varying
    BEGIN
        vhola := 'Hola World';
        RETURN vhola;
    END;
$BODY$;

ALTER FUNCTION microrest.hello_world()
    OWNER TO dba;

INSERT INTO microrest.restapi
    (id_restapi, "name", "path", query, "action", required_token)
    (id_restapi, "name", "path", query, "action", required_token)
    VALUES (1,'Hello World','/helloworld','SELECT microrest.hello_world()','GET','0');


-- FUNCTION: microrest.hello_hans()

-- DROP FUNCTION IF EXISTS microrest.hello_hans();

CREATE OR REPLACE FUNCTION microrest.hello_hans(
	)
    RETURNS text
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
SELECT CONCAT('Hello Hans. The current time is: ', now())
$BODY$;

ALTER FUNCTION microrest.hello_hans()
    OWNER TO dba;

INSERT INTO microrest.restapi
    (id_restapi, "name", "path", query, "action", required_token)
    VALUES (2,'Hello Hans','/hellohans','SELECT microrest.hello_hans()','GET','0');

/*
DELETE FROM microrest.restapi
WHERE id_restapi=1
*/


-- test
SELECT microrest.hello_world();
SELECT microrest.hello_hans();

SELECT id_restapi, "name", "path", query, "action", required_token
FROM microrest.restapi;

