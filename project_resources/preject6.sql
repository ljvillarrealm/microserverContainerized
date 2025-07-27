-- --------------------------------  PROJECT 6  --------------------------------------------

-- DROP DATABASE dummylogin;

CREATE DATABASE dummylogin
    WITH
    OWNER = dba
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;


-- DROP SCHEMA loggin CASCADE;

CREATE SCHEMA loggin
    AUTHORIZATION dba;


-- drop table loggin.users;

CREATE TABLE loggin.users
(
    email character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    aud_last_login timestamp with time zone,
    aud_datetime_created timestamp NOT NULL,
    PRIMARY KEY (email)
);

ALTER TABLE IF EXISTS loggin.users
    OWNER to dba;

select * from loggin.users

-- truncate table loggin.users


-- DROP FUNCTION loggin.f_isvalidemail;

CREATE FUNCTION loggin.f_isvalidemail(
	IN p_email character varying
)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	/* 
		returns true (1) if the email is valid, false (0) if not. 
	*/
	DECLARE v_return boolean;
	BEGIN
		v_return := (select p_email ilike '%@%.%');
		/* Here is possible to add more validations */
		RETURN v_return;
	END;
$BODY$;

ALTER FUNCTION loggin.f_isvalidemail(character varying)
    OWNER TO dba;


SELECT loggin.f_isvalidemail('hans@example.com');
SELECT loggin.f_isvalidemail('hansexample.com');
SELECT loggin.f_isvalidemail('hans@dotcom');


-- DROP FUNCTION loggin.f_isvalidpassword;

CREATE FUNCTION loggin.f_isvalidpassword(
	IN p_password text
)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	/* 
		returns true (1) if the password is valid, false (0) if not. 
	*/
	DECLARE v_return boolean;
	BEGIN
		IF (length(p_password)>7) THEN v_return := true;
		ELSE v_return := false;
		END IF;
		/* Here is possible to add more validations
		RAISE NOTICE 'password length: %', length(p_password);
		RAISE NOTICE 'is valid: %', v_return;
        */
		RETURN v_return;
	END;
$BODY$;

ALTER FUNCTION loggin.f_isvalidpassword(text)
    OWNER TO dba;


SELECT loggin.f_isvalidpassword('123456789');
SELECT loggin.f_isvalidpassword('1234567');
SELECT loggin.f_isvalidpassword('12345678');


-- DROP FUNCTION loggin.f_create_user;

CREATE FUNCTION loggin.f_create_user(
	IN p_body text
)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	/* 
		returns a message error if the user is not possible to create
	*/
	DECLARE
		v_email character varying(50);
		v_password character varying(50);
		v_name character varying(150);
		v_last_name character varying(150);
		v_return text;
		v_cleanfuncexists boolean;
	BEGIN
		-- essert existence of the function loggin.f_cleanjsoninput
		v_cleanfuncexists := (SELECT EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'f_cleanjsoninput' AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'loggin')));

		v_return := '';
		-- json paser
		IF (v_cleanfuncexists) THEN
			v_email := loggin.f_cleanjsoninput(p_body::json->'email');
			v_password := loggin.f_cleanjsoninput(p_body::json->'password');
			v_name := loggin.f_cleanjsoninput(p_body::json->'name');
			v_last_name := loggin.f_cleanjsoninput(p_body::json->'last_name');
		ELSE
			v_email := p_body::json->'email';
			v_password := p_body::json->'password';
			v_name := p_body::json->'name';
			v_last_name := p_body::json->'last_name';
		END IF;

		-- validate email
		IF NOT(loggin.f_isvalidemail(v_email)) THEN
			v_return := CONCAT('{"result":"error","description":"email is not valid", "datetime":"', NOW(), '"}');
		END IF;

		-- validate password
		IF NOT(loggin.f_isvalidpassword(v_password)) THEN
			v_return := CONCAT('{"result":"error","description":"password is not valid (length must be 8 or more)", "datetime":"', NOW(), '"}');
		END IF;

		-- validate user not exists
		IF EXISTS(SELECT 1 FROM loggin.users WHERE email=v_email) THEN
			v_return := CONCAT('{"result":"error","description":"user already exists", "datetime":"', NOW(), '"}');
		END IF;

		-- insert user if validations pass
		IF (v_return='') THEN
			INSERT INTO loggin.users
				(email, "password", "name", last_name, aud_last_login, aud_datetime_created)
				VALUES(v_email, v_password, v_name, v_last_name, NULL, NOW());
			-- validate user was created
			IF EXISTS(SELECT 1 FROM loggin.users WHERE email=v_email) THEN
				v_return := CONCAT('{"result":"info","description":"user was created succesfully", "datetime":"', NOW(), '"}');
			END IF;
		END IF;

		/* Here is possible to add more validations */
		RETURN v_return;
	END;
$BODY$;

ALTER FUNCTION loggin.f_create_user(text)
    OWNER TO dba;


/* not possible to assert
SELECT loggin.f_create_user('{"email": "hans@example.com", "password": "123456789", "name": "Hans", "last_name": "Vil"}');
SELECT loggin.f_create_user('{"email": "hans2.com", "password": "123456789", "name": "Hans", "last_name": "Vil"}');
SELECT loggin.f_create_user('{"email": "hans3@example.com", "password": "123", "name": "Hans", "last_name": "Vil"}');
SELECT loggin.f_create_user('{"email": "hans@example.com", "password": "123456789", "name": "Hans", "last_name": "Vil"}');
*/



-- DELETE FROM microrest.restapi WHERE id_restapi=100

INSERT INTO microrest.restapi
    (id_restapi, "name", "path", query, "action", required_token)
    VALUES (100,'Create user','/usercreate/v1','SELECT loggin.f_create_user(body)','POST','0');

select * from microrest.restapi where id_restapi=100


/*

{
    "email": "hans@example.com", 
    "password": "123456789", 
    "name": "Hans", 
    "last_name": "Vil"
}

*/


-- DROP FUNCTION loggin.f_cleanjsoninput;

CREATE FUNCTION loggin.f_cleanjsoninput(
	IN p_json json
)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	/* 
		removes double quotes from json structures. 
	*/
	BEGIN
		RETURN REPLACE(p_json::text, '"', '');
	END;
$BODY$;

ALTER FUNCTION loggin.f_cleanjsoninput(json)
    OWNER TO dba;


-- SELECT EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'f_cleanjsoninput' AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'loggin'))



-- DROP FUNCTION loggin.f_validateuser;

CREATE FUNCTION loggin.f_validateuser(
	IN p_body json
)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	/* 
		returns a message error if the user is not possible to create
	*/
	DECLARE
		v_email character varying(50);
		v_password character varying(50);
		v_return text;
		v_cleanfuncexists boolean;
	BEGIN
		-- essert existence of the function loggin.f_cleanjsoninput
		v_cleanfuncexists := (SELECT EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'f_cleanjsoninput' AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'loggin')));

		v_return := '';
		-- json paser
		IF (v_cleanfuncexists) THEN
			v_email := loggin.f_cleanjsoninput(p_body::json->'email');
			v_password := loggin.f_cleanjsoninput(p_body::json->'password');
		ELSE
			v_email := p_body::json->'email';
			v_password := p_body::json->'password';
		END IF;

		-- validate user not exists
		IF EXISTS(SELECT 1 FROM loggin.users WHERE email=v_email AND password=v_password) THEN
			v_return := CONCAT('{"result":"info","description":"user login ok", "datetime":"', NOW(), '"}');
		ELSE
			v_return := CONCAT('{"result":"error","description":"user or password incorrect", "datetime":"', NOW(), '"}');
		END IF;

		/* Here is possible to add more validations */
		RETURN v_return;
	END;
$BODY$;

ALTER FUNCTION loggin.f_validateuser(json)
    OWNER TO dba;


-- DELETE FROM microrest.restapi WHERE id_restapi=151

INSERT INTO microrest.restapi
    (id_restapi, "name", "path", query, "action", required_token)
    VALUES (151,'Validate user login','/validateuserlogin/v1','SELECT loggin.f_validateuser(body)','GET','0');

select * from microrest.restapi where id_restapi=151

/*

{
    "email": "hans@example.com", 
    "password": "123456789"
}

*/

