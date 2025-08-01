CREATE SCHEMA microrest
    AUTHORIZATION dba;

CREATE TABLE microrest.users
(
    users character varying(50) COLLATE pg_catalog."default" NOT NULL,
    password character varying(50) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (users)
)

TABLESPACE pg_default;

ALTER TABLE microrest.users
    OWNER to dba;



CREATE TABLE microrest.token
(
    users character varying(20) COLLATE pg_catalog."default" NOT NULL,
    token character varying(100) COLLATE pg_catalog."default" NOT NULL,
    created timestamp with time zone DEFAULT now(),
    CONSTRAINT ptoken PRIMARY KEY (token)
)

TABLESPACE pg_default;

ALTER TABLE microrest.token
    OWNER to dba;



CREATE TABLE microrest.restapi
(
    id_restapi bigint NOT NULL,
    name character varying COLLATE pg_catalog."default" NOT NULL,
    path character varying COLLATE pg_catalog."default",
    query character varying COLLATE pg_catalog."default",
    action character varying(20) COLLATE pg_catalog."default",
    required_token character(1) COLLATE pg_catalog."default",
    CONSTRAINT restapi_pkey PRIMARY KEY (id_restapi)
)

TABLESPACE pg_default;

ALTER TABLE microrest.restapi
    OWNER to dba;

ALTER TABLE microrest.restapi
    OWNER to dba;






CREATE TABLE microrest.sync_conf
(
    table_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    key_field character varying(150) COLLATE pg_catalog."default",
    key_type character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT sync_conf_pkey PRIMARY KEY (table_name)
)

TABLESPACE pg_default;

ALTER TABLE microrest.sync_conf
    OWNER to dba;
    
    
    
    
    
-- Table: microrest.sync_data

-- DROP TABLE microrest.sync_data;

CREATE TABLE microrest.sync_data
(
    id bigint NOT NULL, -- DEFAULT nextval('microrest.sinc_id_seq'::regclass),
    table_name character varying(150) COLLATE pg_catalog."default" NOT NULL,
    sync character(1) COLLATE pg_catalog."default" NOT NULL,
    mode character varying(90) COLLATE pg_catalog."default",
    key_value character varying(150) COLLATE pg_catalog."default",
    CONSTRAINT sinc_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;    
    
    
    
    


CREATE OR REPLACE FUNCTION microrest.check_token(
	ptoken character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE vdias int;
  BEGIN
    IF EXISTS(SELECT * FROM microrest.token WHERE token=ptoken) THEN
		vdias:=(SELECT date_part('day',now()-created) FROM microrest.token WHERE token=ptoken);
		IF (vdias>0) THEN
			DELETE FROM microrest.token WHERE token=ptoken;
            RETURN CONCAT('{"MSG":"EXPIRED"}');
        END IF;
			RETURN CONCAT('{"MSG":"OK"}');	
	ELSE
		RETURN '{"MSG":"NO AUTH","ERROR":"COD1"}';
    END IF;
  return '{"MSG":"NO AUTH","ERROR":"COD2"}';
END;
$BODY$;

ALTER FUNCTION microrest.check_token(character varying)
    OWNER TO dba;






CREATE OR REPLACE FUNCTION microrest.create_token(
	pauth character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
   vtemp character varying;
   vuser character varying;
   vpassword character varying;
   vtoken character varying;   
   pauth1 character varying;   
   pauth2 character varying;   
   
  BEGIN
	
	pauth1 := (select split_part(trim(pauth),' ',1));
	pauth2 := (select split_part(trim(pauth),' ',2));
	
	IF (pauth1 <> 'Basic') THEN
		RETURN '{"MSG":"NO AUTH","ERROR":"COD1"}';
	END IF;
	
	vtemp := (select convert_from(decode(pauth2, 'base64'), 'UTF8'));
	RAISE NOTICE 'vtemp %',vtemp;
	vuser := (SELECT split_part(vtemp,':', 1));
	vpassword := (SELECT split_part(vtemp,':', 2));
	IF (vuser='' or vpassword='') THEN
		RETURN '{"MSG":"NO AUTH","ERROR":"COD2"}';
	END IF;
	
	IF (EXISTS(SELECT * FROM microrest.users WHERE users=vuser and password=vpassword)) THEN
		vtoken := (uuid_in(md5(random()::text || clock_timestamp()::text)::cstring));
		INSERT INTO microrest.token(users,token) VALUES (vuser,vtoken);
		RETURN '{"MSG":"OK","TOKEN":"'|| vtoken ||'"}';	
	ELSE
		RETURN '{"MSG":"NO AUTH","ERROR":"COD3"}';
	END IF;
	
	
	
	RETURN '{"MSG":"NO AUTH"}';
  END;
$BODY$;

ALTER FUNCTION microrest.create_token(character varying)
    OWNER TO dba;


-- FUNCTION: microrest.example1(bigint, character varying, character varying, character varying)

-- DROP FUNCTION microrest.example1(bigint, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION microrest.example1(
	pparam1 bigint,
	pparam2 character varying,
	pheader1 character varying,
	body character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
   vsalida character varying;
  BEGIN
	
	vsalida := '{"EXE":"EXAMPLE2",MSG":"OK"}';
	
	RAISE NOTICE 'Param 1 %',pparam1;
	RAISE NOTICE 'Param 2 %',pparam2;
	RAISE NOTICE 'header1 %',pheader1;
	RAISE NOTICE 'body %',body;
	
	return vsalida;
  END;
$BODY$;

ALTER FUNCTION microrest.example1(bigint, character varying, character varying, character varying)
    OWNER TO dba;
