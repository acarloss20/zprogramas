        SELECT  c~company_code,
                c~deal_number,
                c~valuation_class,
                d~flowtype,
                d~bustranscat,
                d~trldate,
                d~amount_cat,
                d~valuation_curr,
               SUM( d~position_amt ) AS position_amt,
               SUM( d~valuation_amt ) AS valuation_amt
        FROM @lt_ifintran AS a
        JOIN vtbfha AS b
        ON ( b~bukrs = a~companycode
        AND  b~rfha  = a~financialtransaction )
        JOIN dift_pos_ident AS c
        ON ( c~company_code = a~companycode
        AND  c~deal_number  = a~financialtransaction
        AND  c~product_type = b~sgsart
        AND  c~context      = @c_trl )
        JOIN trlv_query AS d
        ON ( d~position_oid = c~identified_oid
        AND  d~bustranscat IN ( @c_1011, @c_2400, @c_8000, @c_9000 )
        AND ( d~booking_state EQ @c_l OR d~booking_state EQ @c_2 ) )
        WHERE d~trldate LE @l_date_last_day
        GROUP BY c~company_code,c~deal_number, c~valuation_class, d~flowtype,
                 d~bustranscat, d~trldate, d~amount_cat, d~valuation_curr
        INTO TABLE @DATA(lt_trlv).


*        IF lt_dift_pos[] IS NOT INITIAL.
*
*          SORT lt_dift_pos[] BY identified_oid.
*
*          SELECT FROM trlv_query
*            FIELDS position_oid,
*                   flowtype,
*                   bustranscat,
*                   trldate,
*                   amount_cat,
*                   valuation_curr,
*                   position_amt,
*                   valuation_amt
*            FOR ALL ENTRIES IN @lt_dift_pos[]
*            WHERE position_oid EQ @lt_dift_pos-identified_oid
*              AND bustranscat IN ( @c_1011, @c_2400, @c_8000, @c_9000 )
*              AND trldate      LE @l_date_last_day
*              AND ( booking_state EQ @c_l OR booking_state EQ @c_2 )
*            INTO TABLE @DATA(lt_trlv).

        SORT lt_trlv[] BY company_code
                          deal_number
                          flowtype
                          trldate.

        LOOP AT lt_trlv ASSIGNING FIELD-SYMBOL(<fs_trlv>).

*            READ TABLE lt_dift_pos ASSIGNING FIELD-SYMBOL(<fs_trlv>) WITH KEY identified_oid = <fs_trlv>-position_oid
*                                                                           BINARY SEARCH.

          IF sy-subrc IS INITIAL.

            IF <fs_trlv>-trldate LT <fs_date>-date.

              lwa_sum_trlv-company_code   = <fs_trlv>-company_code.
              lwa_sum_trlv-deal_number    = <fs_trlv>-deal_number.
              lwa_sum_trlv-flowtype       = <fs_trlv>-flowtype.
              lwa_sum_trlv-bustranscat    = <fs_trlv>-bustranscat.
              lwa_sum_trlv-valuation_curr = <fs_trlv>-valuation_curr.
              lwa_sum_trlv-position_amt   = <fs_trlv>-position_amt.
              lwa_sum_trlv-valuation_amt  = <fs_trlv>-valuation_amt.

              IF ( lwa_sum_trlv-bustranscat EQ c_1011 OR lwa_sum_trlv-bustranscat EQ c_2400 ) AND
                 ( <fs_trlv>-valuation_class EQ c_class_61 OR <fs_trlv>-valuation_class EQ c_class_961 ).
                lwa_sum_trlv-prazo = c_c.

              ELSE.
                lwa_sum_trlv-prazo = COND #( WHEN <fs_trlv>-valuation_class IN r_class_curto[]
                                                THEN c_c
                                             WHEN <fs_trlv>-valuation_class IN r_class_longo[]
                                                THEN c_l ).
              ENDIF.

              COLLECT lwa_sum_trlv INTO lt_sum_trlv[].
              CLEAR lwa_sum_trlv.

            ENDIF.

            IF <fs_trlv>-trldate LE <fs_date>-date.

              lwa_sum_trlv_le-company_code   = <fs_trlv>-company_code.
              lwa_sum_trlv_le-deal_number    = <fs_trlv>-deal_number.
              lwa_sum_trlv_le-flowtype       = <fs_trlv>-flowtype.
              lwa_sum_trlv_le-bustranscat    = <fs_trlv>-bustranscat.
              lwa_sum_trlv_le-valuation_curr = <fs_trlv>-valuation_curr.
              lwa_sum_trlv_le-position_amt   = <fs_trlv>-position_amt.
              lwa_sum_trlv_le-valuation_amt  = <fs_trlv>-valuation_amt.

              IF ( lwa_sum_trlv_le-bustranscat EQ c_1011 OR lwa_sum_trlv_le-bustranscat EQ c_2400 ) AND
                 ( <fs_trlv>-valuation_class EQ c_class_61 OR <fs_trlv>-valuation_class EQ c_class_961 ).
                lwa_sum_trlv_le-prazo = c_c.

              ELSE.
                lwa_sum_trlv_le-prazo = COND #( WHEN <fs_trlv>-valuation_class IN r_class_curto[]
                                                  THEN c_c
                                                WHEN <fs_trlv>-valuation_class IN r_class_longo[]
                                                  THEN c_l ).
              ENDIF.

              COLLECT lwa_sum_trlv_le INTO lt_sum_trlv_le[].
              CLEAR lwa_sum_trlv_le.

              lwa_sum_trlv_data-company_code   = <fs_trlv>-company_code.
              lwa_sum_trlv_data-deal_number    = <fs_trlv>-deal_number.
              lwa_sum_trlv_data-flowtype       = <fs_trlv>-flowtype.
              lwa_sum_trlv_data-bustranscat    = <fs_trlv>-bustranscat.
              lwa_sum_trlv_data-trldate        = <fs_trlv>-trldate.
              lwa_sum_trlv_data-valuation_curr = <fs_trlv>-valuation_curr.
              lwa_sum_trlv_data-position_amt   = <fs_trlv>-position_amt.
              lwa_sum_trlv_data-valuation_amt  = <fs_trlv>-valuation_amt.

              IF ( lwa_sum_trlv_data-bustranscat EQ c_1011 OR lwa_sum_trlv_data-bustranscat EQ c_2400 ) AND
                 ( <fs_trlv>-valuation_class EQ c_class_61 OR <fs_trlv>-valuation_class EQ c_class_961 ).
                lwa_sum_trlv_data-prazo = c_c.

              ELSE.
                lwa_sum_trlv_data-prazo = COND #( WHEN <fs_trlv>-valuation_class IN r_class_curto[]
                                                    THEN c_c
                                                  WHEN <fs_trlv>-valuation_class IN r_class_longo[]
                                                    THEN c_l ).
              ENDIF.

              COLLECT lwa_sum_trlv_data INTO lt_sum_trlv_data[].
              CLEAR lwa_sum_trlv_data.

              lwa_sum_trlv_data_2-company_code   = <fs_trlv>-company_code.
              lwa_sum_trlv_data_2-deal_number    = <fs_trlv>-deal_number.
              lwa_sum_trlv_data_2-bustranscat    = <fs_trlv>-bustranscat.
              lwa_sum_trlv_data_2-trldate        = <fs_trlv>-trldate.
              lwa_sum_trlv_data_2-amount_cat     = <fs_trlv>-amount_cat.
              lwa_sum_trlv_data_2-valuation_curr = <fs_trlv>-valuation_curr.
              lwa_sum_trlv_data_2-position_amt   = <fs_trlv>-position_amt.
              lwa_sum_trlv_data_2-valuation_amt  = <fs_trlv>-valuation_amt.

              IF ( lwa_sum_trlv_data_2-bustranscat EQ c_1011 OR lwa_sum_trlv_data_2-bustranscat EQ c_2400 ) AND
                 ( <fs_trlv>-valuation_class EQ c_class_61 OR <fs_trlv>-valuation_class EQ c_class_961 ).
                lwa_sum_trlv_data_2-prazo = c_c.

              ELSE.
                lwa_sum_trlv_data_2-prazo = COND #( WHEN <fs_trlv>-valuation_class IN r_class_curto[]
                                                  THEN c_c
                                                WHEN <fs_trlv>-valuation_class IN r_class_longo[]
                                                  THEN c_l ).
              ENDIF.

              COLLECT lwa_sum_trlv_data_2 INTO lt_sum_trlv_data_2[].
              CLEAR lwa_sum_trlv_data_2.

              lwa_sum_trlv_mes-company_code   = <fs_trlv>-company_code.
              lwa_sum_trlv_mes-deal_number    = <fs_trlv>-deal_number.
              lwa_sum_trlv_mes-flowtype       = <fs_trlv>-flowtype.
              lwa_sum_trlv_mes-bustranscat    = <fs_trlv>-bustranscat.
              lwa_sum_trlv_mes-mes            = <fs_trlv>-trldate(6).
              lwa_sum_trlv_mes-valuation_curr = <fs_trlv>-valuation_curr.
              lwa_sum_trlv_mes-position_amt   = <fs_trlv>-position_amt.
              lwa_sum_trlv_mes-valuation_amt  = <fs_trlv>-valuation_amt.

              IF ( lwa_sum_trlv_mes-bustranscat EQ c_1011 OR lwa_sum_trlv_mes-bustranscat EQ c_2400 ) AND
                 ( <fs_trlv>-valuation_class EQ c_class_61 OR <fs_trlv>-valuation_class EQ c_class_961 ).
                lwa_sum_trlv_mes-prazo = c_c.

              ELSE.
                lwa_sum_trlv_mes-prazo = COND #( WHEN <fs_trlv>-valuation_class IN r_class_curto[]
                                                   THEN c_c
                                                 WHEN <fs_trlv>-valuation_class IN r_class_longo[]
                                                   THEN c_l ).
              ENDIF.

              COLLECT lwa_sum_trlv_mes INTO lt_sum_trlv_mes[].
              CLEAR lwa_sum_trlv_mes.

              lwa_sum_trlv_mes_2-company_code   = <fs_trlv>-company_code.
              lwa_sum_trlv_mes_2-deal_number    = <fs_trlv>-deal_number.
              lwa_sum_trlv_mes_2-flowtype       = <fs_trlv>-flowtype.
              lwa_sum_trlv_mes_2-bustranscat    = <fs_trlv>-bustranscat.
              lwa_sum_trlv_mes_2-mes            = <fs_trlv>-trldate(6).
              lwa_sum_trlv_mes_2-valuation_curr = <fs_trlv>-valuation_curr.
              lwa_sum_trlv_mes_2-position_amt   = <fs_trlv>-position_amt.
              lwa_sum_trlv_mes_2-valuation_amt  = <fs_trlv>-valuation_amt.

              IF ( lwa_sum_trlv_mes_2-bustranscat EQ c_1011 OR lwa_sum_trlv_mes_2-bustranscat EQ c_2400 ) AND
                 ( <fs_trlv>-valuation_class EQ c_class_61 OR <fs_trlv>-valuation_class EQ c_class_961 ).
                lwa_sum_trlv_mes_2-prazo = c_c.

              ELSE.
                lwa_sum_trlv_mes_2-prazo = COND #( WHEN <fs_trlv>-valuation_class IN r_class_curto[]
                                                     THEN c_c
                                                   WHEN <fs_trlv>-valuation_class IN r_class_longo[]
                                                     THEN c_l ).
              ENDIF.

              COLLECT lwa_sum_trlv_mes_2 INTO lt_sum_trlv_mes_2[].
              CLEAR lwa_sum_trlv_mes_2.

              lwa_sum_trlv_mes_amount_cat-company_code   = <fs_trlv>-company_code.
              lwa_sum_trlv_mes_amount_cat-deal_number    = <fs_trlv>-deal_number.
              lwa_sum_trlv_mes_amount_cat-bustranscat    = <fs_trlv>-bustranscat.
              lwa_sum_trlv_mes_amount_cat-mes            = <fs_trlv>-trldate(6).
              lwa_sum_trlv_mes_amount_cat-amount_cat     = <fs_trlv>-amount_cat.
              lwa_sum_trlv_mes_amount_cat-valuation_curr = <fs_trlv>-valuation_curr.
              lwa_sum_trlv_mes_amount_cat-position_amt   = <fs_trlv>-position_amt.
              lwa_sum_trlv_mes_amount_cat-valuation_amt  = <fs_trlv>-valuation_amt.

              IF ( lwa_sum_trlv_mes_amount_cat-bustranscat EQ c_1011 OR lwa_sum_trlv_mes_amount_cat-bustranscat EQ c_2400 ) AND
                 ( <fs_trlv>-valuation_class EQ c_class_61 OR <fs_trlv>-valuation_class EQ c_class_961 ).
                lwa_sum_trlv_mes_amount_cat-prazo = c_c.

              ELSE.
                lwa_sum_trlv_mes_amount_cat-prazo = COND #( WHEN <fs_trlv>-valuation_class IN r_class_curto[]
                                                              THEN c_c
                                                            WHEN <fs_trlv>-valuation_class IN r_class_longo[]
                                                              THEN c_l ).
              ENDIF.

              COLLECT lwa_sum_trlv_mes_amount_cat INTO lt_sum_trlv_mes_amount_cat[].
              CLEAR lwa_sum_trlv_mes_amount_cat.


              lwa_sum_trlv_mes_amount_cat_2-company_code   = <fs_trlv>-company_code.
              lwa_sum_trlv_mes_amount_cat_2-deal_number    = <fs_trlv>-deal_number.
              lwa_sum_trlv_mes_amount_cat_2-bustranscat    = <fs_trlv>-bustranscat.
              lwa_sum_trlv_mes_amount_cat_2-mes            = <fs_trlv>-trldate(6).
              lwa_sum_trlv_mes_amount_cat_2-amount_cat     = <fs_trlv>-amount_cat.
              lwa_sum_trlv_mes_amount_cat_2-valuation_curr = <fs_trlv>-valuation_curr.
              lwa_sum_trlv_mes_amount_cat_2-position_amt   = <fs_trlv>-position_amt.
              lwa_sum_trlv_mes_amount_cat_2-valuation_amt  = <fs_trlv>-valuation_amt.

              IF ( lwa_sum_trlv_mes_amount_cat_2-bustranscat EQ c_1011 OR lwa_sum_trlv_mes_amount_cat_2-bustranscat EQ c_2400 ) AND
                 ( <fs_trlv>-valuation_class EQ c_class_61 OR <fs_trlv>-valuation_class EQ c_class_961 ).
                lwa_sum_trlv_mes_amount_cat_2-prazo = c_c.

              ELSE.
                lwa_sum_trlv_mes_amount_cat_2-prazo = COND #( WHEN <fs_trlv>-valuation_class IN r_class_curto[]
                                                                THEN c_c
                                                              WHEN <fs_trlv>-valuation_class IN r_class_longo[]
                                                                THEN c_l ).
              ENDIF.

              COLLECT lwa_sum_trlv_mes_amount_cat_2 INTO lt_sum_trlv_mes_amount_cat_2[].
              CLEAR lwa_sum_trlv_mes_amount_cat_2.

            ENDIF.

            lwa_sum_trlv_mes_int-company_code   = <fs_trlv>-company_code.
            lwa_sum_trlv_mes_int-deal_number    = <fs_trlv>-deal_number.
            lwa_sum_trlv_mes_int-flowtype       = <fs_trlv>-flowtype.
            lwa_sum_trlv_mes_int-bustranscat    = <fs_trlv>-bustranscat.
            lwa_sum_trlv_mes_int-mes            = <fs_trlv>-trldate(6).
            lwa_sum_trlv_mes_int-valuation_curr = <fs_trlv>-valuation_curr.
            lwa_sum_trlv_mes_int-position_amt   = <fs_trlv>-position_amt.
            lwa_sum_trlv_mes_int-valuation_amt  = <fs_trlv>-valuation_amt.

            IF ( lwa_sum_trlv_mes_int-bustranscat EQ c_1011 OR lwa_sum_trlv_mes_int-bustranscat EQ c_2400 ) AND
               ( <fs_trlv>-valuation_class EQ c_class_61 OR <fs_trlv>-valuation_class EQ c_class_961 ).
              lwa_sum_trlv_mes_int-prazo = c_c.

            ELSE.
              lwa_sum_trlv_mes_int-prazo = COND #( WHEN <fs_trlv>-valuation_class IN r_class_curto[]
                                                     THEN c_c
                                                   WHEN <fs_trlv>-valuation_class IN r_class_longo[]
                                                     THEN c_l ).
            ENDIF.

            COLLECT lwa_sum_trlv_mes_int INTO lt_sum_trlv_mes_int[].
            CLEAR lwa_sum_trlv_mes_int.

          ENDIF.

        ENDLOOP.
