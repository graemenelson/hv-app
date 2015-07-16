$ ->
  unless typeof gon is 'undefined'
    braintree.setup(gon.braintree_client_token, 'dropin', {
      container: 'braintree-form-inputs',
      onPaymentMethodReceived: (obj) ->
        form = $('#braintree-form-inputs').parents('form').first()
        form.find("input[name='signup[payment_method_nonce]']").val(obj.nonce)
        form.find("input[name='signup[payment_method_type]']").val(obj.type)
        form.submit()
    });
