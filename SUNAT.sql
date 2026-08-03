/*
================================================================================
  REPORTE SUNAT
  Institucion : Culqi (6022)
                1. Ejecución con LIMIT 100 --> se sube
                2. Ejecución de toda la data completa --> se sube
                
                Presentarsela a Jose Carlos Mamami
================================================================================
*/
-- QUERY OFICIAL
select
	'20100047218' AS ruc_informante,                          --NUEVO: RUC BCP
	case
		WHEN ht.nbr_resolutor = 'VISA' 				THEN '05'
		WHEN ht.nbr_resolutor = 'MASTERCARD' 		THEN '05'
		WHEN ht.nbr_resolutor = 'PAGO EFECTIVO' 	THEN '05'
		WHEN ht.nbr_resolutor = 'IZIPAY'		 	THEN '01'
		WHEN ht.nbr_resolutor = 'NIUBIZ' 			THEN '03'
		WHEN ht.nbr_resolutor = 'NIUBIZ POS' 		THEN '03'
		WHEN ht.nbr_resolutor = 'NIUBIZ ECOMMERCE' 	THEN '03'
		WHEN ht.nbr_resolutor = 'PAGO QR NIUBIZ' 	THEN '03'
		WHEN ht.nbr_resolutor = 'NO IDENTIFICADO' 	THEN '03'
		WHEN ht.nbr_resolutor = 'SWITCH' 			THEN '03'
	END AS tipo_operador,
	case
		WHEN ht.nbr_resolutor = 'VISA' 				THEN ''
		WHEN ht.nbr_resolutor = 'MASTERCARD' 		THEN ''
		WHEN ht.nbr_resolutor = 'PAGO EFECTIVO' 	THEN '20464993879'
		WHEN ht.nbr_resolutor = 'IZIPAY' 			THEN ''
		WHEN ht.nbr_resolutor = 'NIUBIZ' 			THEN ''
		WHEN ht.nbr_resolutor = 'NIUBIZ POS' 		THEN ''
		WHEN ht.nbr_resolutor = 'NIUBIZ ECOMMERCE' 	THEN ''
		WHEN ht.nbr_resolutor = 'PAGO QR NIUBIZ' 	THEN ''
		WHEN ht.nbr_resolutor = 'NO IDENTIFICADO' 	THEN ''
		WHEN ht.nbr_resolutor = 'SWITCH' 			THEN ''
	END AS ruc_operador,
	case
		WHEN ht.nbr_resolutor = 'VISA' 				THEN 'VISA INTL SERVICIOS DE PAGO ESPANA,S.R.L'
		WHEN ht.nbr_resolutor = 'MASTERCARD' 		THEN 'Mastercard International'
		WHEN ht.nbr_resolutor = 'PAGO EFECTIVO' 	THEN 'ORBIS VENTURES S.A.C'
		WHEN ht.nbr_resolutor = 'IZIPAY' 			THEN ''
		WHEN ht.nbr_resolutor = 'NIUBIZ' 			THEN ''
		WHEN ht.nbr_resolutor = 'NIUBIZ POS' 		THEN ''
		WHEN ht.nbr_resolutor = 'NIUBIZ ECOMMERCE' 	THEN ''
		WHEN ht.nbr_resolutor = 'PAGO QR NIUBIZ' 	THEN ''
		WHEN ht.nbr_resolutor = 'NO IDENTIFICADO' 	THEN ''
		WHEN ht.nbr_resolutor = 'SWITCH' 			THEN ''
	END AS razon_social_operador,
	case
		WHEN mc.tip_documento = 'DNI' 	THEN '01'
		WHEN mc.tip_documento = 'RUC' 	THEN '06'
		WHEN mc.tip_documento = 'CE' 	THEN '04'
		WHEN mc.tip_documento = 'OTRO' 	THEN '09'
		ELSE '09'
	END AS tipo_documento,
	mc.num_documento 	AS numero_documento,
	mcc.nbr_mcc 		AS actividad_economica,
	COALESCE(cd_com.nbr_departamento, cd_fis.nbr_departamento)  AS departamento,
	COALESCE(cd_com.nbr_provincia, cd_fis.nbr_provincia)        AS provincia,
	COALESCE(cd_com.nbr_distrito, cd_fis.nbr_distrito)          AS distrito,
	mc.nbr_razonsocial 	AS nombre,
	COALESCE( CASE WHEN cd_com.nbr_direccion != 'NO ESPECIFICADA' THEN cd_com.nbr_direccion END, cd_fis.nbr_direccion, mdc.dir_comercio, mdc.dir_legal_comercio) AS direccion,
	case
		WHEN ht.tip_tarjeta = 'DEBITO'          THEN 'd'
		WHEN ht.tip_tarjeta = 'CREDITO'         THEN 'c'
		WHEN ht.tip_tarjeta = 'INTERNACIONAL'   THEN 'c'
		WHEN ht.tip_tarjeta = 'PREPAGO'         THEN 'd'
		WHEN ht.tip_tarjeta = 'NO IDENTIFICADO' THEN 'd'
		ELSE 'd'
	END AS tipo_tarjeta,
	date_format(ht.fec_dia, '%m/%d/%Y')                            AS fecha,
	date_format(ht.fec_creacion - interval '5' hour, '%H:%i:%S')   AS hora,
	CAST(ht.mto_transaccion_original AS DECIMAL(10,2))  AS monto,
	case
		WHEN ht.nbr_moneda = 'PEN' THEN 's'
		WHEN ht.nbr_moneda = 'USD' THEN 'd'
		ELSE 's'
	END AS moneda,
	case
		WHEN ht.flg_exitoso = true 	THEN '1'
		WHEN ht.flg_exitoso = false THEN '2'
		ELSE '2'
	END AS estado,
	ht.num_referencia_fis 	AS nro_voucher,
	ht.cod_refid 			AS nro_transaccion,
	case 
		when mp.nbr_categoriaproducto = 'ONLINE' then 'Pago Web'
		when mp.nbr_categoriaproducto = 'OFFLINE' then 'POS'
		else 'POS'
	end AS "medio de cobro"
FROM dl_adq.sdl.h_transaccion ht
LEFT JOIN dl_adq.sdl.m_comercio c 				 ON c.sk_comercio = ht.sk_comercio
LEFT JOIN dl_adq.sdl.m_mcc mcc 					 ON mcc.cod_mcc = c.cod_mcc
LEFT JOIN dl_adq.sdl.m_cliente mc 				 ON mc.sk_cliente = c.sk_cliente
LEFT JOIN dl_adq.sdl.m_producto mp 				 ON mp.nbr_producto = ht.nbr_producto
LEFT JOIN dl_adq.sdl.r_comercio_direccion cd_com ON cd_com.sk_comercio = c.sk_comercio AND cd_com.tip_direccion = 'COMERCIAL'
LEFT JOIN dl_adq.sdl.r_comercio_direccion cd_fis ON cd_fis.sk_comercio = c.sk_comercio AND cd_fis.tip_direccion = 'FISCAL'
LEFT JOIN dl_pfc.silver.md_comercio mdc 		 ON mdc.id_comercio_core = CAST(ht.cod_comercio_c1 AS integer)
where
	ht.cod_origen_culqi 			 		= 'C2'
	AND ht.cod_respuesta_transaccion 		in ('593','00')
	AND ht.cod_estadocomercio_transaccion 	in ('01','02','04','05','06','07','08','12')
	and ht.nbr_resolutor                    in ('VISA','MASTERCARD','PAGO EFECTIVO','IZIPAY','NIUBIZ','NIUBIZ POS',
												'NIUBIZ ECOMMERCE','PAGO QR NIUBIZ','NO IDENTIFICADO','SWITCH')
	and mc.num_documento                    is not null
	AND ht.cod_refid 						is not null
	AND ht.nbr_resolutor 					is not null
	AND ht.num_referencia_fis 				is not null
	--and ht.fec_creacion >= date '2026-02-01' and ht.fec_creacion <= date '2026-02-28'
	and ht.fec_dia >= date '2026-07-01' and ht.fec_dia <= date '2026-07-31'
limit 100;

