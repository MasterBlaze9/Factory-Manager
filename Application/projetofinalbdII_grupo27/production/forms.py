from django import forms


class WorkTypeForm(forms.Form):
    designation = forms.CharField(
        label='Designação', max_length=50, required=True, widget=forms.TextInput(attrs={'class': 'form-control'}))
    cost_per_hour = forms.DecimalField(
        label='Custo por hora', max_digits=7, decimal_places=2, required=True, widget=forms.NumberInput(attrs={'class': 'form-control'}))
