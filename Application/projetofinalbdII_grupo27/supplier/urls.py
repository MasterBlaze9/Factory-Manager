from django.urls import path
from . import views

urlpatterns = [
    path('list/', views.getSuppliersList, name='list'),
    path('create/', views.createSupplier, name='create'),
    path('edit/<int:supplier_id>',
         views.editSupplier, name='edit'),
    path('delete/<int:supplier_id>', views.softDeleteSupplier, name='delete'),
]
