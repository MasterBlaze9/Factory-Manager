from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .forms import *
from .database import *


@login_required(login_url='/user/login')
def getWorkTypesList(request):
    data = worktype_GetList(request.user.is_staff)
    return render(request, './production/worktypes_list.html', {'data': data})


@login_required(login_url='/user/login')
def createWorkType(request):
    if request.method == 'POST':
        designation = request.POST.get('designation')
        cost = request.POST.get('cost')

        worktype_Create(request.user.is_staff, designation, cost, request.user.id)

        return redirect('/production/worktype/list')

    initial_data = {
        'worktype_id': 0,
        'designation': "",
        'cost': "",
    }

    return render(request, './production/create_update_worktype.html', {'form': initial_data})


@login_required(login_url='/user/login')
def editWorkType(request, worktype_id):
    worktype = worktype_GetById(request.user.is_staff, worktype_id)

    form = {
        'worktype_id': worktype[0],
        'designation': worktype[1],
        'cost': worktype[2]
    }

    if request.method == 'POST':
        designation = request.POST.get('designation')
        cost = request.POST.get('cost')

        worktype_Update(request.user.is_staff, worktype_id, designation, cost)

        return redirect('/production/worktype/list')

    return render(request, './production/create_update_worktype.html', {'form': form})


@login_required(login_url='/user/login')
def softDeleteWorkType(request, worktype_id):
    if request.method == 'POST':
        worktype_SoftDelete(request.user.is_staff, worktype_id)

        return redirect('/production/worktype/list')

    worktype = worktype_GetById(request.user.is_staff, worktype_id)
    form = {
        'designation': worktype[1]
    }

    return render(request, './production/delete_worktype.html', {'form': form})

@login_required(login_url='/user/login')
def getProductionsList(request):
    data = production_GetList(request.user.is_staff)
    return render(request, './production/productions_list.html', {'data': data})


@login_required(login_url='/user/login')
def createProduction(request):
    if request.method == 'POST':
        designation = request.POST.get('designation')
        cost = request.POST.get('cost')

        production_Create(request.user.is_staff, designation, cost, request.user.id)

        return redirect('/production/production/list')

    initial_data = {
        'production_id': 0,
        'designation': "",
        'cost': "",
    }

    return render(request, './production/create_update_production.html', {'form': initial_data})