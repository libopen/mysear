BATDIC={"秋季":"09","春季":"03","秋":"09","春":"03"}
STUCATEDIC={"开放":"01","助力":"06","普招":"02","一村一":"04"}
PRODIC={"本科(专科起点)":"2","专科":"4"}
def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        pass

    try:
        import unicodedata
        unicodedata.numeric(s)
        return True
    except (TypeError,ValueError):
        pass
    return False

def removelast(str):
    return str[:-2] if str[-2:]=='.0' else str