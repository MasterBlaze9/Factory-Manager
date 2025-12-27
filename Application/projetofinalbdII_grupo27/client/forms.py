from django import forms


class ClientForm(forms.Form):
    name = forms.CharField(label="Nome", max_length=100, required=True)
    address = forms.CharField(label="Morada", max_length=100, required=True)
