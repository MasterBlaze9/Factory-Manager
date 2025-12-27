from django import forms
from .database import *

class CreateOrUpdateEquipment(forms.Form):
    designation = forms.CharField(max_length=100, widget=forms.TextInput(attrs={'class': 'form-control'}))
    description = forms.CharField(max_length=100, widget=forms.TextInput(attrs={'class': 'form-control'}))
    price = forms.DecimalField(widget=forms.NumberInput(attrs={'class': 'form-control'}))   
    equipment_types = forms.ChoiceField(choices=equipmenttype_GetList(True), widget=forms.Select(attrs={'class': 'form-control'}))