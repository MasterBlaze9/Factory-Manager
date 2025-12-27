/* aluno9_a PRIVILEGES */
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO aluno9_a;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO aluno9_a;
/*==================*/

/* aluno9_b PRIVILEGES */
/* SELECT PRIVILEGES */
GRANT SELECT ON component TO aluno9_b;
GRANT SELECT ON client TO aluno9_b;
GRANT SELECT ON equipmenttype TO aluno9_b;
GRANT SELECT ON supplier TO aluno9_b;
GRANT SELECT ON supplier_component TO aluno9_b;
GRANT SELECT ON worktype TO aluno9_b;
GRANT SELECT ON warehouse TO aluno9_b;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO aluno9_b;
/*==================*/

/* ALL PRIVILEGES */
DO $$
DECLARE 
    var_table_name RECORD;
	cursor_SchemaTables CURSOR FOR (
		SELECT table_name
		FROM information_schema.tables
		WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
			AND table_name NOT IN ('component', 'client', 'equipmenttype', 'supplier', 'supplier_component', 'worktype', 'warehouse')
	);
BEGIN
    FOR var_table_name IN cursor_SchemaTables
    LOOP
        EXECUTE 'GRANT ALL PRIVILEGES ON public.' || var_table_name.table_name || ' TO aluno9_b';
    END LOOP;
END $$;
/*==================*/

/* VIEWS PRIVILEGES */
DO $$
DECLARE 
    var_view_name RECORD;
	cursor_SchemaViews CURSOR FOR (
		SELECT table_name
		FROM information_schema.views
		WHERE table_schema = 'public'
	);
BEGIN
    FOR var_view_name IN cursor_SchemaViews
    LOOP
        EXECUTE 'GRANT SELECT ON TABLE public.' || var_view_name.table_name || ' TO aluno9_b';
    END LOOP;
END $$;

/* FUNCTION PRIVILEGES */
DO $$
DECLARE 
    var_function_name RECORD;
	cursor_SchemaFunctions CURSOR FOR (
		SELECT routine_name
		FROM information_schema.routines
		WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'
	);
BEGIN
    FOR var_function_name IN cursor_SchemaFunctions
    LOOP
        EXECUTE 'GRANT EXECUTE ON FUNCTION public.' || var_function_name.routine_name || ' TO aluno9_b';
    END LOOP;
END $$;
/*==================*/
/*==================*/