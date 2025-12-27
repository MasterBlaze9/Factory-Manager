from django import forms


class SupplierForm(forms.Form):
    name = forms.CharField(label="Nome", max_length=100, required=True)
    address = forms.CharField(label="Morada", max_length=100, required=True)
    fiscalNumber = forms.CharField(label="NIF", max_length=9, required=True)
