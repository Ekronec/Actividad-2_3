/*
create or replace function fn_tipotran(
    p_idtipo number
) return varchar2
as
    v_nomtipo TIPO_TRANSACCION_TARJETA.NOMBRE_TPTRAN_TARJETA%type;
begin

    select nombre_tptran_tarjeta
    into v_nomtipo
    from TIPO_TRANSACCION_TARJETA
    where COD_TPTRAN_TARJETA = p_idtipo;
    return v_nomtipo;
    
end fn_tipotran;
/

create or replace function fn_nomprof(
    p_codprof number
) return varchar2
as
    v_nomprof profesion_oficio.nombre_prof_ofic%type;
begin
    select NOMBRE_PROF_OFIC
    into v_nomprof
    from profesion_oficio
    where p_codprof = cod_prof_ofic;
    return v_nomprof;
end fn_nomprof;
/
*/
/*
declare

    -- CURSORES
    cursor c_tarjcli is
        select *
        from TARJETA_CLIENTE;
        
    cursor c_tran (p_nrotarj number) is
        select *
        from  TRANSACCION_TARJETA_CLIENTE
        where p_nrotarj = nro_tarjeta
        and to_char(fecha_transaccion, 'yyyy') = to_char(sysdate, 'yyyy') - 1
        order by to_char(fecha_transaccion, 'mm') asc;
    -- VARIABLES
    v_dvrun cliente.DVRUN%type;
    v_puntos number;
    v_nomcodprof number;
    v_fecnac cliente.FECHA_NACIMIENTO%type;
    v_edad number;
    v_montototal number;
    
    type t_datos is varray(4) of number;
    v_datos t_datos := t_datos(250,300,550,700);

begin
    execute IMMEDIATE 'truncate table DETALLE_PUNTOS_TARJETA_CATB';
    
    
    for r_tarjcli in c_tarjcli loop
    
        select dvrun,
               COD_PROF_OFIC,
               FECHA_NACIMIENTO
        into v_dvrun, v_nomcodprof, v_fecnac
        from cliente
        where r_tarjcli.numrun = NUMRUN;
        
        v_edad := round(months_between(sysdate, v_fecnac) / 12);
        v_montototal := 0;
    
        for r_tran in c_tran (r_tarjcli.nro_tarjeta) loop
            
            v_montototal := v_montototal + r_tran.MONTO_TOTAL_TRANSACCION; 
            
            if v_nomcodprof = 21 or v_edad > 60 then
                v_puntos := (trunc(r_tran.monto_transaccion/100000)) * (v_datos(1) + 
                        case
                           when v_montototal between 500000 and 700000 then v_datos(2)
                           when v_montototal between 700001 and 900000 then v_datos(3)
                           when v_montototal > 900001 then v_datos(4)
                           else 0
                        end);
            else
                v_puntos := (trunc(r_tran.monto_transaccion/100000)) * (v_datos(1));
            end if;
            
            
        
            pl(r_tarjcli.numrun
            ||' '|| v_dvrun
            ||' '|| r_tran.nro_tarjeta
            ||' '|| r_tran.nro_transaccion
            ||' '|| r_tran.fecha_transaccion
            ||' '|| fn_tipotran(r_tran.COD_TPTRAN_TARJETA)
            ||' '|| r_tran.monto_transaccion
            ||' '|| v_puntos
            );
            
            insert into DETALLE_PUNTOS_TARJETA_CATB
            values(r_tarjcli.numrun
            , v_dvrun
            , r_tran.nro_tarjeta
            , r_tran.nro_transaccion
            , r_tran.fecha_transaccion
            , fn_tipotran(r_tran.COD_TPTRAN_TARJETA)
            , r_tran.monto_transaccion
            , nvl(v_puntos, 0)
            );
        
        end loop;
    
    
    
    end loop;

end;
*/



-- CASO 2

declare

    -- CURSORES
    cursor c_tarjcli is
        select *
        from TARJETA_CLIENTE;
        
    cursor c_tran (p_nrotarj number) is
        select *
        from  TRANSACCION_TARJETA_CLIENTE
        where p_nrotarj = nro_tarjeta
        and to_char(fecha_transaccion, 'yyyy') = to_char(sysdate, 'yyyy') - 1
        order by to_char(fecha_transaccion, 'mm') asc;
    -- VARIABLES
    v_dvrun cliente.DVRUN%type;
    
begin
    
    
    for r_tarjcli in c_tarjcli loop
    
        select dvrun
        into v_dvrun
        from cliente
        where r_tarjcli.numrun = NUMRUN;
        
    
        for r_tran in c_tran (r_tarjcli.nro_tarjeta) loop
            
            
            
        
            pl(r_tarjcli.numrun
            ||' '|| v_dvrun
            ||' '|| r_tran.nro_tarjeta
            ||' '|| r_tran.nro_transaccion
            ||' '|| r_tran.fecha_transaccion
            ||' '|| fn_tipotran(r_tran.COD_TPTRAN_TARJETA)
            ||' '|| r_tran.monto_total_transaccion
            );
            
        
        end loop;
    
    
    
    end loop;

end;
/

