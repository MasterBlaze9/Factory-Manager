from django.urls import path
from . import views

urlpatterns = [
    path('list/', views.getClientsList, name='list_client'),
    path('create/', views.createClient, name='create_client'),
    path('edit/<int:client_id>',
         views.editClient, name='edit_client'),
    path('delete/<int:client_id>', views.softDeleteClient, name='delete_client'),
]
