  METHOD get_version_process.

    DATA: lv_internal_version TYPE /gfxdsi/ernf_internal_version,
          ls_rnftc014         TYPE /gfxdsi/rnftc014,
          lv_domvalue         TYPE dd07v-domvalue_l,
          lv_ddtext           TYPE dd07v-ddtext.

    SELECT internal_version
      FROM /gfxdsi/rnftc014
      UP TO 1 ROWS
      INTO CORRESPONDING FIELDS OF ls_rnftc014
      WHERE legal_event_type = iv_legal_event
        AND active = abap_true
      ORDER BY internal_version DESCENDING.
    ENDSELECT.

    IF sy-subrc <> 0.
      IF iv_with_cx IS NOT INITIAL.
        RAISE EXCEPTION TYPE cx_hrpaybr_exception
          EXPORTING
            textid = /gfxdsi/cx_reinf=>reinf_version_not_found.
      ELSE.
        rv_version = /gfxdsi/if_reinf_util=>mc_event_header-reinf_version_003.
        RETURN.
      ENDIF.
    ENDIF.

    lv_domvalue = ls_rnftc014-internal_version.
    CALL FUNCTION 'DOMAIN_VALUE_GET'
      EXPORTING
        i_domname  = '/GFXDSI/DRNF_INTERNAL_VERSION'
        i_domvalue = lv_domvalue
      IMPORTING
        e_ddtext   = lv_ddtext
      EXCEPTIONS
        not_exist  = 1
        OTHERS     = 2.

    rv_version = lv_ddtext.

  ENDMETHOD.
