from django.urls import path
from . import views

urlpatterns = [
    path('list/', views.getWarehousesList, name='list_warehouse'),
    path('create/', views.createWarehouse, name='create_warehouse'),
    path('edit/<int:warehouse_id>',
         views.editWarehouse, name='edit_warehouse'),
    path('delete/<int:warehouse_id>', views.softDeleteWarehouse, name='delete_warehouse'),
]
