from django.urls import path
from . import views


urlpatterns = [
    path("worktype/list/",views.getWorkTypesList, name="list_worktype"),
    path("worktype/create/",views.createWorkType, name="create_worktype"),
    path("worktype/edit/<int:worktype_id>/",views.editWorkType, name="edit_worktype"),
    path("worktype/delete/<int:worktype_id>/",views.softDeleteWorkType, name="delete_worktype"),
    path("production/list/",views.getProductionsList, name="list_production"),
    path("production/create/",views.createProduction, name="create_production"),
]