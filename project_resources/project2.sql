-- --------------------------------  PROJECT 2  --------------------------------------------


-- DROP FUNCTION microrest.saludate(int8, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION microrest.saludate(
	p_first_name character varying
	, p_last_name character varying
	)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
   v_output character varying;
  BEGIN
	
	v_output := 'Hi ' || p_first_name || ' ' || p_last_name || '. The time is: ' || now();
	
	return v_output;
  END;
$function$
;

SELECT microrest.saludate('Hans', 'Vil');

INSERT INTO microrest.restapi
    (id_restapi, "name", "path", query, "action", required_token)
    VALUES (3,'Saludate','/saludate','SELECT microrest.saludate(''first_name'', ''last_name'')','GET','0');


-- DROP FUNCTION microrest.saludatejson(int8, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION microrest.saludatejson(
	p_first_name character varying
	, p_last_name character varying
	)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
   v_output character varying;
  BEGIN
	
	v_output := json_build_object('name:', p_first_name, 'last name', p_last_name, 'Curent time', now());
	
	return v_output;
  END;
$function$
;


SELECT microrest.saludatejson('Hans', 'Vil');

INSERT INTO microrest.restapi
    (id_restapi, "name", "path", query, "action", required_token)
    VALUES (4,'Saludate JSON','/saludatejson','SELECT microrest.saludatejson(''first_name'', ''last_name'')','GET','0');

