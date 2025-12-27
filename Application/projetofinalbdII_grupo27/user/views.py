from django.shortcuts import render
from django.db import connection
from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required


@login_required(login_url='/user/login')
def show_users(request):
    template_name = './user/users_list.html'

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM show_users")
        view_data = cursor.fetchall()

    context = {
        'view_data': view_data,
    }
    return render(request, template_name, context)


def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        user = authenticate(username=username, password=password)
        if user is not None:
            login(request, user)
            return redirect('/component/to_order_list/')
        else:
            return render(request, './user/login.html', {'error': 'Credênciais inválidas'})

    return render(request, './user/login.html')


@login_required(login_url='/user/login')
def signout(request):
    logout(request)
    return redirect('/user/login')
