from django.urls import path
from . import views

urlpatterns = [
    path('list/', views.getComponentsList, name='list_component'),
    path('handle_imported_components/', views.handle_imported_components,
         name='handle_imported_components'),
    path('handle_export_components/', views.handle_export_components,
         name='handle_export_components'),
    path('to_order_list/', views.getComponentsToOrderList, name='list_component_to_order'),
    path('order_summary/', views.orderSummary,
         name='order_summary'),
    path('createOrder', views.createOrder,
         name='createOrder'),
    path('create/', views.createComponent, name='create_component'),
    path('edit/<int:component_id>/',
         views.editComponent, name='edit_component'),
    path('delete/<int:component_id>/',
         views.softDeleteComponent, name='delete_component'),
    path('orders/list/', views.getOrdersList, name="orders_list"),
    path('handle_export_orders/', views.handle_export_orders,
         name='handle_export_orders'),
    path('orders/detail/<int:order_id>/', views.getOrderDetail, name="order_detail"),
    path('orders/register_delivery/', views.registerOrderDelivery, name="order_register_delivery"),
    path('createOrderDeliveryComponent', views.createOrderDeliveryComponent,
         name='createOrderDeliveryComponent'),
    #! DEPRECATED path('registerOrderComponentDelivery/', views.registerOrderComponentDelivery, name="registerOrderComponentDelivery"),
    path('getOrderInvoiceDetails/', views.getOrderInvoiceDetails, name="getOrderInvoiceDetails"),
]