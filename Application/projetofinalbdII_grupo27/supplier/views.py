from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .forms import *
from .database import *


@login_required(login_url='/user/login')
def getSuppliersList(request):
    data = supplier_GetList(request.user.is_staff)
    return render(request, './supplier/suppliers_list.html', {'data': data})


@login_required(login_url='/user/login')
def createSupplier(request):
    if request.method == 'POST':
        name = request.POST.get('name')
        address = request.POST.get('address')
        fiscal_number = request.POST.get('fiscal_number')
        selectedComponents = request.POST.getlist("components")

        error_message = supplier_Create(request.user.is_staff, name, address,
                                        fiscal_number, request.user.id)

        if error_message != None and error_message != "":
            data = {
                "supplier": {
                    'supplier_id': 0,
                    'name': name,
                    'address': address,
                    'fiscal_number': fiscal_number,
                },
                "components": supplier_GetComponents_SelectedOrToSelect(request.user.is_staff, 0),
                "error_message": error_message,
            }
            return render(request, './supplier/create_update_supplier.html', data)

        error_message = ""
        for component_id in selectedComponents:
            error_message = supplierComponent_Create(
                request.user.is_staff, supplier_GetLastSupplierId(request.user.is_staff), component_id, request.user.id)

            if error_message != None and error_message != "":
                supplier_SoftDelete(request.user.is_staff,
                                    supplier_GetLastSupplierId(request.user.is_staff))

                data = {
                    "supplier": {
                        'supplier_id': 0,
                        'name': name,
                        'address': address,
                        'fiscal_number': fiscal_number,
                    },
                    "components": supplier_GetComponents_SelectedOrToSelect(request.user.is_staff, 0),
                    "error_message": error_message,
                }
                return render(request, './supplier/create_update_supplier.html', data)

        return redirect('/supplier/list')

    data = {
        "supplier": {
            'supplier_id': 0,
            'name': "",
            'address': "",
            'fiscal_number': "",
        },
        "components": supplier_GetComponents_SelectedOrToSelect(request.user.is_staff, 0)
    }

    return render(request, './supplier/create_update_supplier.html', data)


@login_required(login_url='/user/login')
def editSupplier(request, supplier_id):
    supplier = supplier_GetById(request.user.is_staff, supplier_id)

    data = {
        "supplier": {
            'supplier_id': supplier_id,
            'name': supplier[1],
            'address': supplier[2],
            'fiscal_number': supplier[3],
        },
        "components": supplier_GetComponents_SelectedOrToSelect(request.user.is_staff, supplier_id)
    }

    if request.method == 'POST':
        name = request.POST.get('name')
        address = request.POST.get('address')
        fiscal_number = request.POST.get('fiscal_number')
        selectedComponents = request.POST.getlist("components")

        error_message = supplier_Update(request.user.is_staff, supplier_id,
                                        name, address, fiscal_number)

        if error_message != None and error_message != "":
            data = {
                "supplier": {
                    'supplier_id': supplier_id,
                    'name': name,
                    'address': address,
                    'fiscal_number': fiscal_number,
                },
                "components": supplier_GetComponents_SelectedOrToSelect(request.user.is_staff, supplier_id),
                "error_message": error_message,
            }
            return render(request, './supplier/create_update_supplier.html', data)

        error_message = ""
        supplierComponent_DeleteBySupplierId(
            request.user.is_staff, supplier_id)
        for component_id in selectedComponents:
            error_message = supplierComponent_Create(
                request.user.is_staff, supplier_id, component_id, request.user.id)

            if error_message != None and error_message != "":
                data = {
                    "supplier": {
                        'supplier_id': 0,
                        'name': name,
                        'address': address,
                        'fiscal_number': fiscal_number,
                    },
                    "components": supplier_GetComponents_SelectedOrToSelect(request.user.is_staff, supplier_id),
                    "error_message": error_message,
                }
                return render(request, './supplier/create_update_supplier.html', data)

        return redirect('/supplier/list')

    return render(request, './supplier/create_update_supplier.html', data)


@login_required(login_url='/user/login')
def softDeleteSupplier(request, supplier_id):
    if request.method == 'POST':
        supplier_SoftDelete(request.user.is_staff, supplier_id)
        supplierComponent_DeleteBySupplierId(
            request.user.is_staff, supplier_id)

        return redirect('/supplier/list')

    supplier = supplier_GetById(request.user.is_staff, supplier_id)
    form = {
        'name': supplier[1]
    }

    return render(request, './supplier/delete_supplier.html', {'form': form})
