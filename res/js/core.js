
/*
  core
  Author: PerterPon<PerterPon@gmail.com>
  Create: Sat Aug 08 2015 07:45:58 GMT+0800 (CST)
*/

"use strict";

$( function() {
  $( '.btn-default' ).on( 'click', function() {
    var recaptcha_challenge_field = $( '#recaptcha_challenge_field' ).val();
    var recaptcha_response_field  = $( '#recaptcha_response_field' ).val();
    var vin_number                = $( '#vin_number' ).val();

    if( 7 !== vin_number.length ) {
      return alert( '车架号位数不对, 请输入后7位车架号' );
    }

    if ( '' === recaptcha_response_field.trim() ) {
      return alert( '请输入验证码' );
    }

    $( '.result-box' ).html( '<div class="loading"></div>' );
    $.ajax( {
      'url'    : '/vin',
      'method' : 'POST',
      'data'   : {
        recaptcha_challenge_field : recaptcha_challenge_field,
        recaptcha_response_field  : recaptcha_response_field,
        vin                       : vin_number
      },
      'success' : function ( data ) {
        $( '.result-box' ).html( '' );
        if ( 'object' !== typeof data ) {
          $( '.result-box' ).html( '<div class="error">当前查询通道拥挤, 请稍后重试</div>' );
          return;
        }
        if ( true === data.wrong ) {
          $( '.result-box' ).html( '<div class="error">'+ data.msg +'</div>' );
          return;
        }

        for( var item in data ) {
          var itemData = data[ item ];
          $( '.result-box' ).append( '<h3>' + item + '</h3>' );
          var $table = $( '<table class="table .table-striped"></table>' );
          for( var i = 0; i < itemData.length; i ++ ) {
            var tr = itemData[ i ];
            var content = null;
            if ( tr.name && tr.en_name ) {
              content   = tr.name + ' (' + tr.en_name + ')';
            } else {
              content   = tr.name || tr.en_name;
            }
            $table.append( '<tr><td>' + ( tr.id || tr.en_id ) + '</td><td>' + content + '</td></tr>' );
          }
          $( '.result-box' ).append( $table );
        }
      },
      failure: function () {
        $( '.result-box' ).html( '<div class="error">查询超时, 当前查询通道拥挤, 请稍后重试</div>' );
      }
    });
  } );
} );
