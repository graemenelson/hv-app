$ ->
  unless typeof gon is 'undefined'
    braintree.setup(gon.braintree_client_token, 'dropin', { container: 'braintree-form-inputs' });
