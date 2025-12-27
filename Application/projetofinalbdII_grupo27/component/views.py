from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.contrib.auth.decorators import login_required
from django.urls import reverse
from .database import *
from static.global_database import *
from static.functions import *
from xml import etree
from warehouse.database import warehouse_GetList
import json
import xml.etree.ElementTree as ET


@login_required(login_url='/user/login')
def getComponentsList(request):
    data = {
        'components_list': component_GetList(request.user.is_staff),
        "error_message": ""
    }
    return render(request, './component/components_list.html', data)


@login_required(login_url='/user/login')
def handle_imported_components(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        uploaded_file = request.FILES['importComponentsFileInput']

        if get_file_extension(uploaded_file.name) == "json" or get_file_extension(uploaded_file.name) == "xml":
            if get_file_extension(uploaded_file.name) == "json":
                error_message = component_ImportJSON(
                    request.user.is_staff, json.dumps(json.load(uploaded_file)), request.user.id)
            elif get_file_extension(uploaded_file.name) == "xml":
                tree = etree.parse(uploaded_file)
                root = tree.getroot()

                error_message = component_ImportXML(
                    request.user.is_staff, etree.tostring(root, encoding='utf-8').decode('utf-8'), request.user.id)

            if error_message != None and error_message != "":
                data = {
                    "components_list": component_GetList(request.user.is_staff),
                    "error_message": error_message
                }
                return render(request, './component/components_list.html', data)

        return redirect("/component/list")


@login_required(login_url='/user/login')
def handle_export_components(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        extension = request.POST.get('inlineRadioExportExtension')
        extension = extension.lower()
        if extension == "json" or extension == "xml":
            if extension == "json":
                components_list_export = component_ExportJSON(
                    request.user.is_staff)

            elif extension == "xml":
                components_list_export = component_ExportXML(
                    request.user.is_staff)

            if components_list_export:
                file_name = 'lista_componentes_' + get_current_date() + '_' + \
                    get_current_time() + '.' + extension

                response = HttpResponse(
                    components_list_export, content_type='application/' + extension)

                response['Content-Disposition'] = 'attachment; filename="' + \
                    file_name + '"'

                return response


@login_required(login_url='/user/login')
def getComponentsToOrderList(request):
    view_data = component_GetToOrderList(request.user.is_staff)

    context = {
        'view_data': view_data,
    }
    return render(request, './component/components_to_order_list.html', context)


@login_required(login_url='/user/login')
def orderSummary(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        selected_components = request.POST.get('selected_components')

        order_summary = []
        for item in json.loads(selected_components):
            order_summary.append(component_GetComponentForOrder(
                request.user.is_staff, item["component_id"], item["supplier_id"]))

        data = {
            'order_summary': order_summary
        }

        return render(request, './component/order_summary.html', data)


@login_required(login_url='/user/login')
def createComponent(request):
    if request.method == 'POST':
        designation = request.POST.get("designation")
        price = request.POST.get("price")

        error_message = component_Create(
            request.user.is_staff, designation, price, request.user.id)

        if error_message != None and error_message != "":
            data = {
                "component": {
                    "designation": designation,
                    "price": price,
                },
                "error_message": error_message
            }
            return render(request, './component/create_update_component.html', data)

        return redirect('/component/list')

    data = {
        "component": {
            "designation": "",
            "price": "",
        }
    }
    return render(request, './component/create_update_component.html', data)


@login_required(login_url='/user/login')
def editComponent(request, component_id):
    component_data = component_GetById(request.user.is_staff, component_id)

    if request.method == 'POST':
        designation = request.POST.get("designation")
        price = request.POST.get("price")

        error_message = component_Update(
            request.user.is_staff, component_id, designation, price)

        if error_message != None and error_message != "":
            data = {
                "component": {
                    "component_id": component_id,
                    "designation": component_data[1],
                    "price": component_data[2]
                },
                "error_message": error_message
            }
            return render(request, './component/create_update_component.html', data)

        return redirect('/component/list')

    data = {
        "component": {
            "component_id": component_id,
            "designation": component_data[1],
            "price": component_data[2]
        }
    }
    return render(request, './component/create_update_component.html', data)


@login_required(login_url='/user/login')
def softDeleteComponent(request, component_id):
    if request.method == 'POST':
        component_SoftDelete(request.user.is_staff, component_id)

        return redirect('/component/list')

    component = component_GetById(request.user.is_staff, component_id)
    form = {
        'name': component[1]
    }

    return render(request, './component/delete_component.html', {'form': form})


@login_required(login_url='/user/login')
def createOrder(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    template_name = "./component/order_summary.html"

    if request.method == 'POST':
        all_values = request.POST

        components_to_order = []
        component_id = 0
        supplier_id = 0
        identifiers = []
        for key, value in all_values.items():
            if key.startswith("component_supplier_id_"):
                component_id = key.split('_')[3]
                supplier_id = key.split('_')[4]

                if component_id != 0 and supplier_id != 0:
                    inf = {
                        'component_id': component_id,
                        'supplier_id': supplier_id
                    }
                    identifiers.append(inf)

        for ids in identifiers:
            aux_component_id = ids["component_id"]
            aux_supplier_id = ids["supplier_id"]

            component_price = all_values.get(
                f'component_price_{aux_component_id}_{aux_supplier_id}')
            component_quantity = all_values.get(
                f'component_quantity_{aux_component_id}_{aux_supplier_id}')

            component_info = {
                'component_id': aux_component_id,
                'supplier_id': aux_supplier_id,
                'component_price': component_price,
                'component_quantity': component_quantity
            }
            components_to_order.append(component_info)

        if len(components_to_order) > 0:
            orders_Create(request.user.is_staff,
                          request.user.id, request.user.id)
            order_id = orders_GetLastOrderId(request.user.is_staff)

            orderDelivery_Create(request.user.is_staff,
                                 order_id, request.user.id)

            for component in components_to_order:
                orderComponent_Create(request.user.is_staff, order_id, int(component['component_id']), int(component['component_quantity']),
                                      float(component['component_price']), int(component['supplier_id']), request.user.id)

        view_data = orders_GetList(request.user.is_staff)

        context = {
            'view_data': view_data,
        }

        return render(request, './component/orders_list.html', context)

    return render(request, template_name, context)

#! Orders


@login_required(login_url='/user/login')
def getOrdersList(request):
    if request.method == 'GET':
        context = {
            'view_data': orders_GetList(request.user.is_staff),
        }

    return render(request, './component/orders_list.html', context)


@login_required(login_url='/user/login')
def handle_export_orders(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        extension = request.POST.get('inlineRadioExportExtension')
        extension = extension.lower()
        if extension == "json" or extension == "xml":
            if extension == "json":
                orders_list_export = orders_ExportJSON(
                    request.user.is_staff)

            elif extension == "xml":
                orders_list_export = orders_ExportXML(
                    request.user.is_staff)

            if orders_list_export:
                file_name = 'lista_encomendas_componentes_' + get_current_date() + '_' + \
                    get_current_time() + '.' + extension

                response = HttpResponse(
                    orders_list_export, content_type='application/' + extension)

                response['Content-Disposition'] = 'attachment; filename="' + \
                    file_name + '"'

                return response


def buildComponentsToDeliver(order_component_data):
    components_to_deliver = []
    for component in order_component_data:
        if component[9] != "Entregue":
            quantity_ordered = int(0 if component[2] is None else component[2])
            quantity_delivered = int(
                0 if component[3] is None else component[3])
            el = {
                'order_component_id': component[11],
                'component_id': component[0],
                'component_designation': component[1] + ' (' + component[8] + ')',
                'quantity_left_to_order': quantity_ordered - quantity_delivered
            }

            if len(components_to_deliver) == 0 or el not in components_to_deliver:
                components_to_deliver.append(el)

    return components_to_deliver


def buildOrderDetailInfo(isAdmin, order_id, error_message):
    order_component_data = orders_GetOrderComponentsByOrderId(
        isAdmin, order_id)

    context = {
        'order_data': orders_GetDetail(isAdmin, order_id),
        'order_components_data': order_component_data,
        'order_invoices_data': orderInvoice_GetListByOrderId(isAdmin, order_id),
        'components_to_deliver': buildComponentsToDeliver(order_component_data),
        'warehouses_data': warehouse_GetList(isAdmin),
        'error_message': error_message,
    }

    return context


@login_required(login_url='/user/login')
def getOrderDetail(request, order_id):
    if request.method == 'GET':
        return render(request, './component/order_detail.html', buildOrderDetailInfo(request.user.is_staff, order_id, ""))


@login_required(login_url='/user/login')
def registerOrderDelivery(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        selected_components = request.POST.get('selected_components')

        components_to_deliver = orders_GetComponentsToDeliver(
            request.user.is_staff, selected_components)

        order_id = 0
        for component in components_to_deliver:
            order_id = component[10]
            break

        data = {
            'order_id': order_id,
            'components_to_deliver': components_to_deliver,
            'warehouses_data': warehouse_GetList(request.user.is_staff),
            'error_message': ''
        }

        return render(request, './component/order_register_delivery.html', data)


@login_required(login_url='/user/login')
def createOrderDeliveryComponent(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        order_id = request.POST.get('order_id')

        order_component_id = 0
        identifiers = []
        for key, value in request.POST.items():
            if key.startswith("order_component_id_"):
                order_component_id = key.split('_')[3]

                if order_component_id != 0:
                    identifiers.append(order_component_id)

        error_message = orderInvoice_Create(
            request.user.is_staff, datetime.date.today(), request.user.id)
        if error_message != None and error_message != "":
            return HttpResponse(status=500, reason=error_message)

        orderinvoice_id = orderInvoice_GetLastOrderInvoiceId(
            request.user.is_staff)

        error_message = ""
        for order_component_id in identifiers:
            warehouse_id = request.POST.get(
                f'selectWarehouse_{order_component_id}')
            delivered_quantity = request.POST.get(
                f'deliveredQuantity_{order_component_id}')
            delivered_date = request.POST.get(
                f'deliveredDate_{order_component_id}')

            error_message = orderDelivery_Component_Create(
                request.user.is_staff, order_id, order_component_id, warehouse_id, delivered_quantity, delivered_date, orderinvoice_id, request.user.id)
            if error_message != None and error_message != "":
                return HttpResponse(status=500, reason=error_message)

            error_message = ""
            order_component = orderComponent_GetById(
                request.user.is_staff, order_component_id)

            component_id = order_component[0]
            supplier_id = order_component[7]
            unit_price = order_component[5]
            warehouse_component_rec = warehouseComponent_GetByComponentSupplierAndWarehouse(request.user.is_staff, component_id, supplier_id, int(warehouse_id))
            if warehouse_component_rec == None:
                error_message = warehouseComponent_Create(
                    request.user.is_staff, component_id, supplier_id, warehouse_id, delivered_quantity, unit_price, request.user.id)
            else:
                error_message = warehouseComponent_UpdateStock(
                    request.user.is_staff, warehouse_component_rec[0], delivered_quantity)
            if error_message != None and error_message != "":
                return HttpResponse(status=500, reason=error_message)

        return HttpResponse(status=200, content="")

#! DEPRECATED
# @login_required(login_url='/user/login')
# def registerOrderComponentDelivery(request):
#     if request.META.get('HTTP_REFERER') is None:
#         return render(request, '404.html')

#     if request.method == 'POST':
#         order_id = request.POST.get('order_id')
#         order_component_id = request.POST.get('selectOrderComponent')
#         warehouse_id = request.POST.get('selectWarehouse')
#         delivered_quantity = request.POST.get('deliveredQuantity')
#         delivered_date = request.POST.get('deliveredDate')

#         error_message = orderDelivery_Component_Create(
#             request.user.is_staff, order_id, order_component_id, warehouse_id, delivered_quantity, delivered_date, request.user.id)
#         if error_message != None and error_message != "":
#             return render(request, './component/order_detail.html', buildOrderDetailInfo(request.user.is_staff, order_id, error_message))

#         error_message = ""
#         error_message = orderInvoice_CreateWithDetail(
#             request.user.is_staff, order_component_id, delivered_date, order_id, delivered_quantity, request.user.id)
#         if error_message != None and error_message != "":
#             return render(request, './component/order_detail.html', buildOrderDetailInfo(request.user.is_staff, order_id, error_message))

#         return redirect('/component/orders/detail/' + order_id)


@login_required(login_url='/user/login')
def getOrderInvoiceDetails(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'GET':
        order_id = request.GET.get('order_id')
        orderinvoice_id = request.GET.get('orderinvoice_id')
        return HttpResponse(status=200, content=json.dumps(orderInvoice_GetDetailById(request.user.is_staff, order_id, orderinvoice_id), cls=CustomEncoder))
