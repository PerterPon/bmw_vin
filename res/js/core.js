$( function() {
  $( '.btn-default' ).on( 'click', function() {
    var recaptcha_challenge_field = $( '#recaptcha_challenge_field' ).val();
    var recaptcha_response_field  = $( '#recaptcha_response_field' ).val();
    var vin_number                = $( '#vin_number' ).val();
    $( '.result-box' ).html( '<div class="loading"></div>' );

    if( 7 !== vin_number.length ) {
      return alert( '车架号位数不对, 请输入后7位车架号' );
    }

    if ( '' === recaptcha_response_field.trim() ) {
      return alert( '请输入验证码' );
    }

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
        try {
          resData = JSON.parse( data );
        } catch( e ) {
          $( '.result-box' ).html( '<div class="error">当前查询通道拥挤, 请稍后重试</div>' );
          console.log( e );
        }
        if ( true === resData.wrong ) {
          $( '.result-box' ).html( '<div class="error">'+ resData.msg +'</div>' );
          return;
        }

        for( var item in resData ) {
          var itemData = resData[ item ];
          $( '.result-box' ).append( '<h3>' + item + '</h3>' );
          $table = $( '<table class="table .table-striped"></table>' );
          for( var i = 0; i < itemData.length; i ++ ) {
            var tr = itemData[ i ];
            $table.append( '<tr><td>' + tr.id + '</td><td>' + tr.name + '</td></tr>' );
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
