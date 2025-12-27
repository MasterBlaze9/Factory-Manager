from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .forms import *
from .database import *


@login_required(login_url='/user/login')
def getWarehousesList(request):
    data = warehouse_GetList(request.user.is_staff)
    return render(request, './warehouse/warehouses_list.html', {'data': data})


#TODO: Apply error_message to all views
@login_required(login_url='/user/login')
def createWarehouse(request):
    if request.method == 'POST':
        designation = request.POST.get('designation')
        address = request.POST.get('address')

        warehouse_Create(request.user.is_staff, designation, address, request.user.id)

        return redirect('/warehouse/list')

    initial_data = {
        'warehouse_id': 0,
        'designation': "",
        'address': "",
    }

    return render(request, './warehouse/create_update_warehouse.html', {'form': initial_data})


@login_required(login_url='/user/login')
def editWarehouse(request, warehouse_id):
    warehouse = warehouse_GetById(request.user.is_staff, warehouse_id)

    form = {
        'warehouse_id': warehouse[0],
        'designation': warehouse[1],
        'address': warehouse[2]
    }

    if request.method == 'POST':
        designation = request.POST.get('designation')
        address = request.POST.get('address')

        warehouse_Update(request.user.is_staff, warehouse_id, designation, address)

        return redirect('/warehouse/list')

    return render(request, './warehouse/create_update_warehouse.html', {'form': form})


@login_required(login_url='/user/login')
def softDeleteWarehouse(request, warehouse_id):
    if request.method == 'POST':
        warehouse_SoftDelete(request.user.is_staff, warehouse_id)

        return redirect('/warehouse/list')

    warehouse = warehouse_GetById(request.user.is_staff, warehouse_id)
    form = {
        'designation': warehouse[1]
    }

    return render(request, './warehouse/delete_warehouse.html', {'form': form})
