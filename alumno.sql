-- FUNCION QUE RECUPERA NOMBRE DE ZONA
create or replace function fn_zona(
    p_idzona number
) return varchar2
as
    v_zona zona.nomzona%type;
begin
    select nomzona
    into v_zona
    from zona
    where idzona = p_idzona;
    return v_zona;

end fn_zona;
/

variable b_fecha varchar2(8);
exec :b_fecha := '20042023';

declare

    -- CURSOR SIN PARAMETRO QUE RECUPERA LAS CATEGORIAS
    cursor c_cat is
        select *
        from categoria;
    -- CURSOR CON PARAMETROS QUE RECIBIRA EL DATO DEL 1ER CURSOR
    cursor c_emp (p_idcat number) is
        select *
        from empleado
        where idcategoria = p_idcat;
        
        
    -- VARTIABLES ESCALARES
    v_edad number;
    v_antiguedad number;
    v_oficina oficina.diroficina%type;
    v_pct number;
    v_bono number;
    v_asiedad number;
    v_total number;
    
    -- VARIABLES ACUMULADORAS
    v_numempleados number := 0;
    v_totalsueldos number := 0;
    
    -- DECLARACION DE UN VARRAY
    type t_datos is varray(4) of number;
    -- crear instancia de array y inicializar
    v_datos t_datos := t_datos(0.2,0.25,0.3,0.4);

begin 
    execute IMMEDIATE 'truncate table DETALLE_BONOS';

    -- ITERAMOS CON FOR SOBRE EL 1ER CURSOR
    for r_cat in c_cat loop
    
        v_numempleados := 0;
        v_totalsueldos := 0;
        
        for r_emp in c_emp (r_cat.idcategoria) loop
        
            v_numempleados := v_numempleados + 1;
            
            -- CALCULO DE LA EDAD Y ANTIGUEDAD
            v_edad := round(months_between(sysdate, r_emp.fecnac) / 12);
            v_antiguedad := round(months_between(sysdate, r_emp.fecing) / 12);
            
            --RESCATAMOS NOMBRE Y % DE OFICINA
            begin
                select diroficina,
                       pct / 100
                into v_oficina, v_pct
                from oficina
                where numoficina = r_emp.numoficina;
            exception
                when no_data_found then
                v_oficina := 'SIN OFICINA';
                v_pct := 0;
            end;
            
            -- CALCULO DE BONO DE ANTIGUEDAD
            v_bono := round(r_emp.sueldo * case
                                        when v_antiguedad < 5 then v_datos(1)
                                        when v_antiguedad between 6 and 9 then v_datos(2)
                                        when v_antiguedad between 10 and 14 then v_datos(3)
                                        else v_datos(4)
                                    end);
                                    
            if v_edad > 50 then
                v_asiedad := round(r_emp.sueldo * v_datos(3));
            else v_asiedad := 0;
            end if;
            
            v_total := v_bono + round(r_emp.sueldo * v_pct) + v_asiedad;
            v_totalsueldos := v_totalsueldos + r_emp.sueldo;
            
            pl(substr(:b_fecha, -6)
            ||' '|| r_emp.rutemp
            ||' '|| r_emp.nombre ||' '|| r_emp.paterno ||' '|| r_emp.materno
            ||' '|| r_emp.sueldo
            ||' '|| v_edad
            ||' '|| v_antiguedad
            ||' '|| v_oficina
            ||' '|| v_pct
            ||' '|| fn_zona(r_emp.idzona)
            ||' '|| v_bono
            ||' '|| round(r_emp.sueldo * v_pct)
            ||' '|| v_asiedad
            ||' '|| v_total
            );
            
            insert into DETALLE_BONOS
            values(substr(:b_fecha, -6)
            , r_emp.rutemp
            , r_emp.nombre ||' '|| r_emp.paterno ||' '|| r_emp.materno
            , r_emp.sueldo
            , nvl(v_edad, 0)
            , v_antiguedad
            , v_oficina
            , fn_zona(r_emp.idzona)
            , v_bono
            , round(r_emp.sueldo * v_pct)
            , v_asiedad
            , v_total);
        
        end loop;
        
        --insert tabla de presupuestos
        
    end loop;

end;