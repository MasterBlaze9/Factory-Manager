from django.urls import path, include
from . import views

urlpatterns = [
    path('list/', views.show_users, name='list'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.signout, name='logout')
]
