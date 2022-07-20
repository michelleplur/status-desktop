
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *

 
def click_on_an_object(objName: str):
    click_obj_by_name(objName)
    
def input_text(text: str, objName: str):
    type(objName, text)
    
def object_not_enabled(objName: str):
    verify_object_enabled(objName, 500, False)
    
def object_enabled(objName: str):
    verify_object_enabled(objName, 500, True)

def verify_text_is_displayed(objName: str, text):
    verify_text_matching(objName, text)
