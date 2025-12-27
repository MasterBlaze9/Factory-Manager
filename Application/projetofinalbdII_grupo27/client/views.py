from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .forms import *
from .database import *


@login_required(login_url='/user/login')
def getClientsList(request):
    data = client_GetList(request.user.is_staff)
    return render(request, './client/clients_list.html', {'data': data})


@login_required(login_url='/user/login')
def createClient(request):
    if request.method == 'POST':
        name = request.POST.get('name')
        address = request.POST.get('address')

        client_Create(request.user.is_staff, name, address, request.user.id)

        return redirect('/client/list')

    initial_data = {
        'client_id': 0,
        'name': "",
        'address': "",
    }

    return render(request, './client/create_update_client.html', {'form': initial_data})


@login_required(login_url='/user/login')
def editClient(request, client_id):
    client = client_GetById(request.user.is_staff, client_id)

    form = {
        'client_id': client[0],
        'name': client[1],
        'address': client[2]
    }

    if request.method == 'POST':
        name = request.POST.get('name')
        address = request.POST.get('address')

        client_Update(request.user.is_staff, client_id, name, address)

        return redirect('/client/list')

    return render(request, './client/create_update_client.html', {'form': form})


@login_required(login_url='/user/login')
def softDeleteClient(request, client_id):
    if request.method == 'POST':
        client_SoftDelete(request.user.is_staff, client_id)

        return redirect('/client/list')

    client = client_GetById(request.user.is_staff, client_id)
    form = {
        'name': client[1]
    }

    return render(request, './client/delete_client.html', {'form': form})
