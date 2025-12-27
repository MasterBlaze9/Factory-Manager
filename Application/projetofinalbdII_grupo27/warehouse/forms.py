from django import forms
from .database import *

class WarehouseEditFrom(forms.Form):
    warehouse_designation = forms.CharField(
        label='Designation', max_length=100, required=True
    )
    warehouse_address = forms.CharField(
        label= 'Morada', max_length=100, required= True
    )
    warehouse_isactive = forms.BooleanField(initial=False, required=False)