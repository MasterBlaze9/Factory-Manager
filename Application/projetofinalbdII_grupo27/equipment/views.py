from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from .database import *
from .database_mongodb import *
from static.global_database import *
from client.database import *
from component.database import *
from production.database import *
from warehouse.database import *
from production.database import *
from .forms import *
from bson import SON


@login_required(login_url='/user/login')
def getEquipmentTypesList(request):
    data = equipmenttype_GetList(request.user.is_staff)
    return render(request, './equipment/equipmenttypes_list.html', {'data': data})


@login_required(login_url='/user/login')
def createEquipmentType(request):
    if request.method == 'POST':
        designation = request.POST.get('designation')

        equipmenttype_Create(request.user.is_staff,
                             designation, request.user.id)

        return redirect('/equipment/type/list')

    equipmentTypeList = equipmenttype_GetList(request.user.is_staff)
    context = {
        'equipment_types_list': equipmentTypeList
    }

    return render(request, './equipment/create_update_equipmenttype.html', context)


@login_required(login_url='/user/login')
def editEquipmentType(request, equipmenttype_id):
    equipmenttype = equipmenttype_GetById(
        request.user.is_staff, equipmenttype_id)

    form = {
        'equipmenttype_id': equipmenttype[0],
        'designation': equipmenttype[1]
    }

    if request.method == 'POST':
        designation = request.POST.get('designation')

        equipmenttype_Update(request.user.is_staff,
                             equipmenttype_id, designation)

        return redirect('/equipment/type/list')

    return render(request, './equipment/create_update_equipmenttype.html', {'form': form})


@login_required(login_url='/user/login')
def softDeleteEquipmentType(request, equipmenttype_id):
    if request.method == 'POST':
        equipmenttype_SoftDelete(request.user.is_staff, equipmenttype_id)

        return redirect('/equipment/type/list')

    equipmenttype = equipmenttype_GetById(
        request.user.is_staff, equipmenttype_id)

    form = {
        'designation': equipmenttype[1]
    }

    return render(request, './equipment/delete_equipmenttype.html', {'form': form})


@login_required(login_url='/user/login')
def getEquipmentsList(request):
    data = equipment_GetList(request.user.is_staff)
    return render(request, './equipment/equipments_list.html', {'data': data})


@login_required(login_url='/user/login')
def create_equipment_view(request):
    if request.method == 'POST':
        designation = request.POST.get('designation')
        description = request.POST.get('description')
        price = request.POST.get('price')
        equipmenttype_id = request.POST.get('selectEquipmentType')
        extra_attribute_label = request.POST.get('extra_attribute_label')
        extra_attribute_value = request.POST.get('extra_attribute_value')

        error_message = equipment_Create(
            request.user.is_staff, designation, description, equipmenttype_id, price,  request.user.id)

        if error_message != None and error_message != "":
            form = {
                "equipment": {
                    "equipment_id": 0,
                    "designation": designation,
                    "description": description,
                    "price": price,
                    "equipmenttype_id": equipmenttype_id,
                    "extra_attribute_label": extra_attribute_label,
                    "extra_attribute_value": extra_attribute_value
                },
                "equipment_types": equipmenttype_GetList(request.user.is_staff),
                "error_message": error_message
            }
            return render(request, './equipment/create_update_equipment.html', form)

        if extra_attribute_label != "":
            if extra_attribute_value != "":
                extra_attribute_value_splitted = extra_attribute_value.split(
                    ",")

                if len(extra_attribute_value_splitted) > 1:
                    extra_values = []
                    for i in range(len(extra_attribute_value_splitted)):
                        extra_values.append(extra_attribute_value_splitted[i])

                    doc = {
                        "postgres_id": equipment_GetLastEquipmentId(request.user.is_staff)[0],
                        extra_attribute_label: extra_values
                    }
                else:
                    doc = {
                        "postgres_id": equipment_GetLastEquipmentId(request.user.is_staff)[0],
                        extra_attribute_label: extra_attribute_value
                    }
            else:
                form = {
                    "equipment": {
                        "equipment_id": 0,
                        "designation": designation,
                        "description": description,
                        "price": price,
                        "equipmenttype_id": equipmenttype_id,
                        "extra_attribute_label": extra_attribute_label,
                        "extra_attribute_value": extra_attribute_value
                    },
                    "equipment_types": equipmenttype_GetList(request.user.is_staff),
                    "error_message": "Valor do atributo extra não pode ser vazio!"
                }

                return render(request, './equipment/create_update_equipment.html', form)
        else:
            doc = {
                "postgres_id": equipment_GetLastEquipmentId(request.user.is_staff)[0]
            }

        bson_doc = SON(doc)
        mongodb_createEquipment(bson_doc)

        return redirect('list_equipment')

    form = {
        "equipment": {
            "equipment_id": 0,
            "designation": "",
            "description": "",
            "price": "",
            "equipmenttype_id": "",
            "extra_attribute_label": "",
            "extra_attribute_value": ""
        },
        "equipment_types": equipmenttype_GetList(request.user.is_staff),
        "error_message": ""
    }
    return render(request, './equipment/create_update_equipment.html', form)


@login_required(login_url='/user/login')
def editEquipment(request, equipment_id):
    equipment = equipment_GetById(request.user.is_staff, equipment_id)
    equipment_mongodb = mongodb_getEquipmentById(equipment_id)

    aux_extra_attribute_label = ""
    aux_extra_attribute_value = ""
    remove_attribute = False
    if equipment_mongodb is not None:
        if len(equipment_mongodb) > 1:
            remove_attribute = True
            aux_extra_attribute_label = list(equipment_mongodb.keys())[1]

            aux = equipment_mongodb[list(equipment_mongodb.keys())[1]]
            if aux is not None:
                if type(aux) == list:
                    for i in range(len(aux)):
                        aux_extra_attribute_value += aux[i] + ","

                    aux_extra_attribute_value = aux_extra_attribute_value[:-1]
                else:
                    aux_extra_attribute_value = aux

    if request.method == 'POST':
        designation = request.POST.get('designation')
        description = request.POST.get('description')
        price = request.POST.get('price')
        equipmenttype_id = request.POST.get('selectEquipmentType')
        extra_attribute_label = request.POST.get('extra_attribute_label')
        extra_attribute_value = request.POST.get('extra_attribute_value')

        error_message = equipment_Update(request.user.is_staff, equipment_id,
                                         designation, description, equipmenttype_id, price)
        if error_message != None and error_message != "":
            form = {
                "equipment": {
                    "equipment_id": equipment_id,
                    "designation": designation,
                    "description": description,
                    "price": price,
                    "equipmenttype_id": equipmenttype_id,
                    "extra_attribute_label": extra_attribute_label,
                    "extra_attribute_value": extra_attribute_value
                },
                "equipment_types": equipmenttype_GetList(request.user.is_staff),
                "error_message": error_message
            }
            return render(request, './equipment/create_update_equipment.html', form)

        if extra_attribute_label != "":
            if extra_attribute_value != "":
                if remove_attribute:
                    mongodb_RemoveExtraAttribute(
                        equipment_id, aux_extra_attribute_label)

                extra_attribute_value_splitted = extra_attribute_value.split(
                    ",")

                if len(extra_attribute_value_splitted) > 1:
                    extra_values = []
                    for i in range(len(extra_attribute_value_splitted)):
                        extra_values.append(extra_attribute_value_splitted[i])

                    doc = {
                        "postgres_id": equipment_id,
                        extra_attribute_label: extra_values
                    }
                else:
                    doc = {
                        "postgres_id": equipment_id,
                        extra_attribute_label: extra_attribute_value
                    }

                bson_doc = SON(doc)
                mongodb_updateEquipment(equipment_id, bson_doc)
            else:
                form = {
                    "equipment": {
                        "equipment_id": 0,
                        "designation": designation,
                        "description": description,
                        "price": price,
                        "equipmenttype_id": equipmenttype_id,
                        "extra_attribute_label": extra_attribute_label,
                        "extra_attribute_value": extra_attribute_value
                    },
                    "equipment_types": equipmenttype_GetList(request.user.is_staff),
                    "error_message": "Valor do atributo extra não pode ser vazio!"
                }

                return render(request, './equipment/create_update_equipment.html', form)
        else:
            if remove_attribute:
                mongodb_RemoveExtraAttribute(
                    equipment_id, aux_extra_attribute_label)

        return redirect('list_equipment')

    form = {
        "equipment": {
            "equipment_id": equipment_id,
            "designation": equipment[1],
            "description": equipment[2],
            "price": equipment[5],
            "equipmenttype_id": equipment[3],
            "extra_attribute_label": aux_extra_attribute_label,
            "extra_attribute_value": aux_extra_attribute_value
        },
        "equipment_types": equipmenttype_GetList(request.user.is_staff),
        "error_message": ""
    }

    return render(request, './equipment/create_update_equipment.html', form)


@login_required(login_url='/user/login')
def getEquipmentDetails(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'GET':
        equipment_id = request.GET.get('equipment_id')

        equipment_mongodb = mongodb_getEquipmentById(int(equipment_id))
        aux_extra_attribute_label = ""
        aux_extra_attribute_value = ""
        if equipment_mongodb is not None:
            if len(equipment_mongodb) > 1:
                aux_extra_attribute_label = list(equipment_mongodb.keys())[1]

                aux = equipment_mongodb[list(equipment_mongodb.keys())[1]]
                if aux is not None:
                    if type(aux) == list:
                        for i in range(len(aux)):
                            aux_extra_attribute_value += aux[i] + ","

                        aux_extra_attribute_value = aux_extra_attribute_value[:-1]
                    else:
                        aux_extra_attribute_value = aux

        if equipment_mongodb is not None:
            data = {
                "equipment": equipment_GetById(request.user.is_staff, equipment_id),
                "equipment_productions": equipment_GetProductionsByEquipmentId(request.user.is_staff, equipment_id),
                "equipment_mongodb": [
                    aux_extra_attribute_label,
                    aux_extra_attribute_value
                ]
            }
        else:
            data = {
                "equipment": equipment_GetById(request.user.is_staff, equipment_id),
                "equipment_productions": equipment_GetProductionsByEquipmentId(request.user.is_staff, equipment_id)
            }

        return HttpResponse(status=200, content=json.dumps(data, cls=CustomEncoder))


@login_required(login_url='/user/login')
def equipmentProduction(request, equipment_id):
    view_data = warehouseComponent_GetList(request.user.is_staff)

    context = {
        'view_data': view_data,
        'equipment_id': equipment_id
    }
    return render(request, './equipment/equipment_production_select_components.html', context)


@login_required(login_url='/user/login')
def equipmentProductionSummary(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        selected_components = request.POST.get('selected_components')

        equipment_production_summary = warehouseComponent_GetByIdList(
            request.user.is_staff, selected_components)

        data = {
            'equipment_production_summary': equipment_production_summary,
            'worktypes': worktype_GetList(request.user.is_staff),
            'warehouses': warehouse_GetList(request.user.is_staff),
            'equipment_id': request.POST.get('equipment_id'),
            'error_message': ""
        }

        return render(request, './equipment/equipment_production_summary.html', data)


@login_required(login_url='/user/login')
def createEquipmentProduction(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        equipment_id = request.POST.get('equipment_id')
        work_type_id = request.POST.get('select_worktype')
        warehouse_id = request.POST.get('select_warehouse')
        quantity_to_produce = int(request.POST.get('quantity_to_produce'))
        start_date = request.POST.get('start_date')
        end_date = request.POST.get('end_date')
        cost = decimal.Decimal(request.POST.get('inputTotalCost'))

        work_type = worktype_GetById(request.user.is_staff, work_type_id)
        work_type_cost = decimal.Decimal(work_type[2])

        error_message = equipmentProduction_Create(request.user.is_staff, equipment_id, work_type_id,
                                                   warehouse_id, quantity_to_produce, start_date, end_date, (cost * work_type_cost), request.user.id)
        if error_message is not None and error_message != "":
            return HttpResponse(status=500, reason=error_message)

        created_equipment_production_id = equipmentProduction_GetLastEquipmentProductionId(
            request.user.is_staff)

        warehouse_component_id = 0
        identifiers = []
        for key, value in request.POST.items():
            if key.startswith("warehouse_component_id_"):
                warehouse_component_id = key.split('_')[3]

                if warehouse_component_id != 0:
                    identifiers.append(warehouse_component_id)

        for i in range(len(identifiers)):
            warehouse_component = warehouseComponent_GetById(
                request.user.is_staff, identifiers[i])
            aux_component_id = warehouse_component[1]
            aux_supplier_id = warehouse_component[3]
            aux_warehouse_id = warehouse_component[5]
            aux_quantity = int(request.POST.get(
                f'quantity_{identifiers[i]}'))

            aux_quantity = aux_quantity * quantity_to_produce
            error_message = equipmentProduction_Component_Create(
                request.user.is_staff, created_equipment_production_id, aux_component_id, aux_supplier_id, aux_warehouse_id, aux_quantity, request.user.id)
            if error_message != None and error_message != "":
                return HttpResponse(status=500, reason=error_message)

        return redirect('list_equipment')


@login_required(login_url='/user/login')
def getEquipmentsToOrderList(request):
    view_data = equipment_GetToOrderList(request.user.is_staff)

    context = {
        'view_data': view_data,
    }
    return render(request, './equipment/equipments_to_order_list.html', context)


@login_required(login_url='/user/login')
def clientOrderSummary(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        selected_equipments = request.POST.get('selected_equipments')

        client_order_summary = equipments_GetByProductionIdList(
            request.user.is_staff, selected_equipments)

        data = {
            'client_order_summary': client_order_summary,
            'clients': client_GetList(request.user.is_staff),
            'error_message': ''
        }

        return render(request, './equipment/client_order_summary.html', data)


@login_required(login_url='/user/login')
def createClientOrder(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        all_values = request.POST
        client_id = request.POST.get('select_client')

        equipment_id = 0
        equipment_production_id = 0
        identifiers = []
        for key, value in all_values.items():
            if key.startswith("equipment_production_id_"):
                equipment_id = key.split('_')[3]
                equipment_production_id = key.split('_')[4]

                if equipment_id != 0 and equipment_production_id != 0:
                    inf = {
                        'equipment_id': equipment_id,
                        'equipment_production_id': equipment_production_id
                    }
                    identifiers.append(inf)

        equipments_to_order = []
        for ids in identifiers:
            aux_equip_id = ids['equipment_id']
            aux_equip_production_id = ids['equipment_production_id']

            equipment_price = all_values.get(
                f'equipment_price_{aux_equip_id}_{aux_equip_production_id}')
            equipment_quantity = all_values.get(
                f'equipment_quantity_{aux_equip_id}_{aux_equip_production_id}')

            equipment_info = {
                'equipment_id': aux_equip_id,
                'equipment_production_id': aux_equip_production_id,
                'equipment_quantity': equipment_quantity,
                'equipment_price': equipment_price
            }
            equipments_to_order.append(equipment_info)

        if len(equipments_to_order) > 0:
            error_message = clientOrder_Create(request.user.is_staff,
                                               client_id, request.user.id, request.user.id)

            if error_message is not None and error_message != "":
                return HttpResponse(status=500, reason=error_message)

            client_order_id = clientOrder_GetLastClientOrderId(
                request.user.is_staff)

            clientOrderDelivery_Create(request.user.is_staff,
                                       client_order_id, request.user.id)

            error_message = ""
            if error_message is not None and error_message != "":
                return HttpResponse(status=500, reason=error_message)

            for equipment in equipments_to_order:
                clientOrderEquipment_Create(request.user.is_staff, client_order_id, int(equipment['equipment_id']), int(equipment['equipment_production_id']), int(equipment['equipment_quantity']),
                                            float(equipment['equipment_price']), request.user.id)
                error_message = ""
                if error_message is not None and error_message != "":
                    return HttpResponse(status=500, reason=error_message)

    return redirect('list_equipment_to_order')


@login_required(login_url='/user/login')
def getClientOrdersList(request):
    if request.method == 'GET':
        context = {
            'view_data': clientOrders_GetList(request.user.is_staff),
        }

    return render(request, './equipment/clientorders_list.html', context)


def buildOrderDetailInfo(isAdmin, client_order_id, error_message):
    context = {
        'client_order_data': clientOrders_GetDetail(isAdmin, client_order_id),
        'client_order_equipments_data': clientOrders_GetClientOrderEquipmentsByClientOrderId(
            isAdmin, client_order_id),
        'client_order_invoices_data': clientOrderInvoice_GetListByClientOrderId(isAdmin, client_order_id),
        'error_message': error_message,
    }

    return context


@login_required(login_url='/user/login')
def getClientOrderDetail(request, client_order_id):
    if request.method == 'GET':
        return render(request, './equipment/clientorder_detail.html', buildOrderDetailInfo(request.user.is_staff, client_order_id, ""))


@login_required(login_url='/user/login')
def registerClientOrderDelivery(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        selected_equipments = request.POST.get('selected_equipments')

        equipments_to_deliver = clientOrders_GetEquipmentsToDeliver(
            request.user.is_staff, selected_equipments)

        client_order_id = 0
        for equipment in equipments_to_deliver:
            client_order_id = equipment[8]
            break

        data = {
            'client_order_id': client_order_id,
            'equipments_to_deliver': equipments_to_deliver,
            'error_message': ''
        }

        return render(request, './equipment/client_order_register_delivery.html', data)


@login_required(login_url='/user/login')
def createClientOrderDeliveryEquipment(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'POST':
        client_order_id = request.POST.get('client_order_id')

        client_order_equipment_id = 0
        identifiers = []
        for key, value in request.POST.items():
            if key.startswith("client_order_equipment_id_"):
                client_order_equipment_id = key.split('_')[4]

                if client_order_equipment_id != 0:
                    identifiers.append(client_order_equipment_id)

        error_message = clientOrderInvoice_Create(
            request.user.is_staff, datetime.date.today(), request.user.id)
        if error_message != None and error_message != "":
            return HttpResponse(status=500, reason=error_message)

        clientorderinvoice_id = clientOrderInvoice_GetLastClientOrderInvoiceId(
            request.user.is_staff)

        error_message = ""
        for client_order_equipment_id in identifiers:
            delivered_quantity = request.POST.get(
                f'deliveredQuantity_{client_order_equipment_id}')
            delivered_date = request.POST.get(
                f'deliveredDate_{client_order_equipment_id}')

            error_message = clientOrderDelivery_Equipment_Create(
                request.user.is_staff, client_order_id, client_order_equipment_id, delivered_quantity, delivered_date, clientorderinvoice_id, request.user.id)
            if error_message != None and error_message != "":
                return HttpResponse(status=500, reason=error_message)

        return HttpResponse(status=200, content="")


@login_required(login_url='/user/login')
def getClientOrderInvoiceDetails(request):
    if request.META.get('HTTP_REFERER') is None:
        return render(request, '404.html')

    if request.method == 'GET':
        client_order_id = request.GET.get('client_order_id')
        clientorderinvoice_id = request.GET.get('clientorderinvoice_id')
        return HttpResponse(status=200, content=json.dumps(clientOrderInvoice_GetDetailById(request.user.is_staff, client_order_id, clientorderinvoice_id), cls=CustomEncoder))


@login_required(login_url='/user/login')
def softDeleteEquipment(request, equipment_id):
    if request.method == 'POST':
        equipment_SoftDelete(request.user.is_staff, equipment_id)

        mongodb_DeleteEquipment(equipment_id)

        return redirect('list_equipment')

    equipment = equipment_GetById(request.user.is_staff, equipment_id)

    form = {
        'designation': equipment[1]
    }

    return render(request, './equipment/delete_equipment.html', {'form': form})
