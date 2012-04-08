login = (event) ->
	event.preventDefault()
	navigator.id.get (assertion) ->
		if assertion
			assertion_field = document.getElementById "assertion-field"
			assertion_field.value = assertion
			login_form = document.getElementById "login-form"
			login_form.submit()

window.onload = ->
	bid = document.getElementById "browserid"
	if bid
		bid.addEventListener "click", login