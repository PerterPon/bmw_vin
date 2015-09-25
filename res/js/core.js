
/*
  core
  Author: PerterPon<PerterPon@gmail.com>
  Create: Sat Aug 08 2015 07:45:58 GMT+0800 (CST)
*/

"use strict";

$( function() {

  var needSecurityCode = false;

  $( 'body' ).on( 'click', '.force_update', function() {
    needForceUpdate();
    window.alert( '请输入验证码，然后从官方地址重新获取生产日期' );
    $( '.result-box' ).html( '' );
  } );

  /**
   * [render 渲染列表]
   * @param  {[type]} data [description]
   * @return {[type]}      [description]
   */
  function render( data ) {
    $( '.result-box' ).html( '' );
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
        var enId = tr.id || tr.en_id;
        var $td  = $( '<tr><td>' + ( enId ) + '</td><td>' + content + '</td></tr>' );
        if( '生产日期' === enId && '0001-01-01' === content.trim() ) {
          $td.find( 'td:eq( 1 )' ).append( '<button class="btn btn-info force_update">强制更新</button>' );
        }
        $table.append( $td );
      }
      $( '.result-box' ).append( $table );
    }
  }

  /**
   * [needForceUpdate 强制更新]
   * @return {[type]} [description]
   */
  function needForceUpdate() {
    needSecurityCode = true;
    $( '.securitycode' ).append( '<iframe id="secury_code_iframe" name="secury_code_iframe" src="/rep.html?3333"></iframe>' );
    $( '#secury_code_iframe' ).on( 'load', function() {
      $( '.loadding', document.secury_code_iframe.document ).remove();
    } );
  }

  $( '.btn-default' ).on( 'click', function() {
    if( true === needSecurityCode ) {
      var recaptcha_challenge_field = $( '#recaptcha_challenge_field', document.secury_code_iframe.document ).val();
      var recaptcha_response_field  = $( '#recaptcha_response_field', document.secury_code_iframe.document ).val();  
    }
    
    var vin_number                  = $( '#vin_number' ).val();

    if( 7 !== vin_number.length ) {
      return alert( '车架号位数不对, 请输入后7位车架号' );
    }

    if ( true === needSecurityCode && '' === recaptcha_response_field.trim() ) {
      return alert( '请输入验证码' );
    }

    var url = needSecurityCode ? '/vin' : '/cache';
    $( '.result-box' ).html( '<div class="loading"></div>' );
    $.ajax( {
      'url'    : url,
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
        render( data );
      },
      error: function ( res ) {
        var status = res.status;
        $( '.loading' ).remove();
        if( 404 === status ) {
          needForceUpdate();
          window.alert( '暂未在本地查询到车架号信息, 请输入验证码从官方地址获取' );
        } else {
          $( '.result-box' ).html( '<div class="error">查询超时, 当前查询通道拥挤, 请稍后重试</div>' );  
        }
        
      }
    });
  } );
} );
