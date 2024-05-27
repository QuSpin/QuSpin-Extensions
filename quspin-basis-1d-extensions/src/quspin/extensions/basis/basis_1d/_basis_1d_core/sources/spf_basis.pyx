# distutils: language=c++

def get_state(L,Ntup=None):
    s = 0
    if Ntup is None:
         MAX = (<object>1 << (2*L))
    else:
        N_left,N_right = Ntup
        MAX = comb(L,N_left,exact=True)*comb(L,N_right,exact=True)
        s = sum(<object>1 << i for i in range(N_left))
        s <<= L
        s += sum(<object>1 << i for i in range(N_right))

       
    return s,MAX

cdef inline bool CheckState_nosymm(basis_type s,basis_type[:] pars):
    cdef basis_type s_right,s_left
    if pars[4] == 0:
        s_right = s & pars[1]
        s_left = s >> pars[0]
        return ((s_right&s_left)==0)
    else:
        return True

def basis(int L,basis_type[:] pars, basis_type[:] basis):
    cdef basis_type s
    cdef npy_intp MAX
    s,MAX = get_state(L)
    return make_basis_template[basis_type](next_state_inc_1,pars,MAX,s,basis)

# magnetization 
def n_basis(int L, object Nf_list, basis_type[:] pars,basis_type[:] basis,NP_INT8_t[:] Np_list=None):
    cdef basis_type s
    cdef npy_intp MAX,Ns
    cdef npy_intp Ns_tot = 0
    for Ntup in Nf_list:
        s,MAX = get_state(L,Ntup)
        N_left,N_right = Ntup
        pars[2] = sum(<object>1 << (L-i-1) for i in range(N_right))
        pars[3] = sum(<object>1 << i for i in range(N_right))
        Ns = make_basis_template[basis_type](next_state_pcon_spf,pars,MAX,s,basis[Ns_tot:])

        if Np_list is not None:
            Np_list[Ns_tot:Ns_tot+Ns] = N_left+N_right
            
        Ns_tot += Ns

    return Ns_tot

# parity 
def n_p_basis(int L, object Nf_list,int pblock,basis_type[:] pars,N_type[:] N,basis_type[:] basis,NP_INT8_t[:] Np_list=None):
    cdef basis_type s
    cdef npy_intp MAX
    cdef npy_intp Ns = 0
    cdef npy_intp Ns_tot = 0
    for Ntup in Nf_list:
        s,MAX = get_state(L,Ntup)
        N_left,N_right = Ntup
        pars[2] = sum(<object>1 << (L-i-1) for i in range(N_right))
        pars[3] = sum(<object>1 << i for i in range(N_right))
        Ns = make_p_basis_template[basis_type,N_type](next_state_pcon_spf,pars,MAX,s,L,pblock,&N[Ns_tot],basis[Ns_tot:])

        if Np_list is not None:
            Np_list[Ns_tot:Ns_tot+Ns] = Ntup
            
        Ns_tot += Ns

    return Ns_tot

def p_basis(int L,int pblock,basis_type[:] pars,N_type[:] N, basis_type[:] basis):
    cdef basis_type s
    cdef npy_intp MAX
    s,MAX = get_state(L)
    return make_p_basis_template[basis_type,N_type](next_state_inc_1,pars,MAX,s,L,pblock,&N[0],basis)


# parity-spin inversion
def n_p_z_basis(int L, object Nf_list, int pblock, int zblock,basis_type[:] pars, N_type[:] N, basis_type[:] basis,NP_INT8_t[:] Np_list=None):
    cdef basis_type s
    cdef npy_intp MAX
    cdef npy_intp Ns = 0
    cdef npy_intp Ns_tot = 0
    for Ntup in Nf_list:
        s,MAX = get_state(L,Ntup)
        N_left,N_right = Ntup
        pars[2] = sum(<object>1 << (L-i-1) for i in range(N_right))
        pars[3] = sum(<object>1 << i for i in range(N_right))
        Ns = make_p_z_basis_template[basis_type,N_type](next_state_pcon_spf,pars,MAX,s,L,pblock,zblock,&N[Ns_tot],basis[Ns_tot:])

        if Np_list is not None:
            Np_list[Ns_tot:Ns_tot+Ns] = Ntup
            
        Ns_tot += Ns

    return Ns_tot   

def p_z_basis(int L, int pblock, int zblock,basis_type[:] pars, N_type[:] N, basis_type[:] basis):
    cdef basis_type s
    cdef npy_intp MAX
    s,MAX = get_state(L)
    return make_p_z_basis_template[basis_type,N_type](next_state_inc_1,pars,MAX,s,L,pblock,zblock,&N[0],basis)


# (parity)*(spin inversion)
def n_pz_basis(int L, object Nf_list, int pzblock,basis_type[:] pars, N_type[:] N, basis_type[:] basis,NP_INT8_t[:] Np_list=None):
    cdef basis_type s
    cdef npy_intp MAX
    cdef npy_intp Ns = 0
    cdef npy_intp Ns_tot = 0
    for Ntup in Nf_list:
        s,MAX = get_state(L,Ntup)
        N_left,N_right = Ntup
        pars[2] = sum(<object>1 << (L-i-1) for i in range(N_right))
        pars[3] = sum(<object>1 << i for i in range(N_right))
        Ns = make_pz_basis_template[basis_type,N_type](next_state_pcon_spf,pars,MAX,s,L,pzblock,&N[Ns_tot],basis[Ns_tot:])

        if Np_list is not None:
            Np_list[Ns_tot:Ns_tot+Ns] = Ntup
            
        Ns_tot += Ns

    return Ns_tot    

def pz_basis(int L, int pzblock,basis_type[:] pars, N_type[:] N, basis_type[:] basis):
    cdef basis_type s
    cdef npy_intp MAX
    s,MAX = get_state(L)
    return make_pz_basis_template[basis_type,N_type](next_state_inc_1,pars,MAX,s,L,pzblock,&N[0],basis)


# translation
def n_t_basis(int L, object Nf_list, int kblock,int a,basis_type[:] pars, N_type[:] N, basis_type[:] basis,NP_INT8_t[:] Np_list=None):
    cdef basis_type s
    cdef npy_intp MAX
    cdef npy_intp Ns = 0
    cdef npy_intp Ns_tot = 0
    for Ntup in Nf_list:
        s,MAX = get_state(L,Ntup)
        N_left,N_right = Ntup
        pars[2] = sum(<object>1 << (L-i-1) for i in range(N_right))
        pars[3] = sum(<object>1 << i for i in range(N_right))
        Ns =  make_t_basis_template[basis_type,N_type](next_state_pcon_spf,pars,MAX,s,L,kblock,a,&N[Ns_tot],basis[Ns_tot:])

        if Np_list is not None:
            Np_list[Ns_tot:Ns_tot+Ns] = Ntup
            
        Ns_tot += Ns

    return Ns_tot

def t_basis(int L, int kblock,int a,basis_type[:] pars, N_type[:] N, basis_type[:] basis):
    cdef basis_type s
    cdef npy_intp MAX
    s,MAX = get_state(L)
    return make_t_basis_template[basis_type,N_type](next_state_inc_1,pars,MAX,s,L,kblock,a,&N[0],basis)


# translation-parity
def n_t_p_basis(int L, object Nf_list,int pblock,int kblock,int a,basis_type[:] pars,N_type[:] N,M1_type[:] M,basis_type[:] basis,NP_INT8_t[:] Np_list=None):
    cdef basis_type s
    cdef npy_intp MAX
    cdef npy_intp Ns = 0
    cdef npy_intp Ns_tot = 0
    for Ntup in Nf_list:
        s,MAX = get_state(L,Ntup)
        N_left,N_right = Ntup
        pars[2] = sum(<object>1 << (L-i-1) for i in range(N_right))
        pars[3] = sum(<object>1 << i for i in range(N_right))
        Ns = make_t_p_basis_template[basis_type,N_type,M1_type](next_state_pcon_spf,pars,MAX,s,L,pblock,kblock,a,&N[Ns_tot],&M[Ns_tot],basis[Ns_tot:])

        if Np_list is not None:
            Np_list[Ns_tot:Ns_tot+Ns] = Ntup
            
        Ns_tot += Ns

    return Ns_tot

def t_p_basis(int L,int pblock,int kblock,int a,basis_type[:] pars,N_type[:] N,M1_type[:] M,basis_type[:] basis):
    cdef basis_type s
    cdef npy_intp MAX
    s,MAX = get_state(L)
    return make_t_p_basis_template[basis_type,N_type,M1_type](next_state_inc_1,pars,MAX,s,L,pblock,kblock,a,&N[0],&M[0],basis)




# translation-parity-spin inversion
def n_t_p_z_basis(int L, object Nf_list,int pblock,int zblock,int kblock,int a,basis_type[:] pars,N_type[:] N,M2_type[:] M,basis_type[:] basis,NP_INT8_t[:] Np_list=None):
    cdef basis_type s
    cdef npy_intp MAX
    cdef npy_intp Ns = 0
    cdef npy_intp Ns_tot = 0
    for Ntup in Nf_list:
        s,MAX = get_state(L,Ntup)
        N_left,N_right = Ntup
        pars[2] = sum(<object>1 << (L-i-1) for i in range(N_right))
        pars[3] = sum(<object>1 << i for i in range(N_right))
        Ns = make_t_p_z_basis_template[basis_type,N_type,M2_type](next_state_pcon_spf,pars,MAX,s,L,pblock,zblock,kblock,a,&N[Ns_tot],&M[Ns_tot],basis[Ns_tot:])

        if Np_list is not None:
            Np_list[Ns_tot:Ns_tot+Ns] = Ntup
            
        Ns_tot += Ns

    return Ns_tot    

def t_p_z_basis(int L,int pblock,int zblock,int kblock,int a,basis_type[:] pars,N_type[:] N,M2_type[:] M,basis_type[:] basis):
    cdef basis_type s
    cdef npy_intp MAX
    s,MAX = get_state(L)
    return make_t_p_z_basis_template[basis_type,N_type,M2_type](next_state_inc_1,pars,MAX,s,L,pblock,zblock,kblock,a,&N[0],&M[0],basis)




# translation-(parity)*(spin inversion)
def n_t_pz_basis(int L, object Nf_list,int pzblock,int kblock,int a,basis_type[:] pars,N_type[:] N,M1_type[:] M,basis_type[:] basis,NP_INT8_t[:] Np_list=None):
    cdef basis_type s
    cdef npy_intp MAX
    cdef npy_intp Ns = 0
    cdef npy_intp Ns_tot = 0
    for Ntup in Nf_list:
        s,MAX = get_state(L,Ntup)
        N_left,N_right = Ntup
        pars[2] = sum(<object>1 << (L-i-1) for i in range(N_right))
        pars[3] = sum(<object>1 << i for i in range(N_right))
        Ns = make_t_pz_basis_template[basis_type,N_type,M1_type](next_state_pcon_spf,pars,MAX,s,L,pzblock,kblock,a,&N[Ns_tot],&M[Ns_tot],basis[Ns_tot:])

        if Np_list is not None:
            Np_list[Ns_tot:Ns_tot+Ns] = Ntup
            
        Ns_tot += Ns

    return Ns_tot   

def t_pz_basis(int L,int pzblock,int kblock,int a,basis_type[:] pars,N_type[:] N,M1_type[:] M,basis_type[:] basis):
    cdef basis_type s
    cdef npy_intp MAX
    s,MAX = get_state(L)
    return make_t_pz_basis_template[basis_type,N_type,M1_type](next_state_inc_1,pars,MAX,s,L,pzblock,kblock,a,&N[0],&M[0],basis)


# translation-spin inversion
def n_t_z_basis(int L, object Nf_list,int zblock,int kblock,int a,basis_type[:] pars,N_type[:] N,M1_type[:] M,basis_type[:] basis,NP_INT8_t[:] Np_list=None):
    cdef basis_type s
    cdef npy_intp MAX
    cdef npy_intp Ns = 0
    cdef npy_intp Ns_tot = 0
    for Ntup in Nf_list:
        s,MAX = get_state(L,Ntup)
        N_left,N_right = Ntup
        pars[2] = sum(<object>1 << (L-i-1) for i in range(N_right))
        pars[3] = sum(<object>1 << i for i in range(N_right))
        Ns = make_t_z_basis_template[basis_type,N_type,M1_type](next_state_pcon_spf,pars,MAX,s,L,zblock,kblock,a,&N[Ns_tot],&M[Ns_tot],basis[Ns_tot:])

        if Np_list is not None:
            Np_list[Ns_tot:Ns_tot+Ns] = Ntup
            
        Ns_tot += Ns

    return Ns_tot

def t_z_basis(int L,int zblock,int kblock,int a,basis_type[:] pars,N_type[:] N,M1_type[:] M,basis_type[:] basis):
    cdef basis_type s
    cdef npy_intp MAX
    s,MAX = get_state(L)
    return make_t_z_basis_template[basis_type,N_type,M1_type](next_state_inc_1,pars,MAX,s,L,zblock,kblock,a,&N[0],&M[0],basis)


# spin inversion
def n_z_basis(int L, object Nf_list, int zblock, basis_type[:] pars,N_type[:] N,basis_type[:] basis,NP_INT8_t[:] Np_list=None):
    cdef basis_type s
    cdef npy_intp MAX
    cdef npy_intp Ns = 0
    cdef npy_intp Ns_tot = 0
    for Ntup in Nf_list:
        s,MAX = get_state(L,Ntup)
        N_left,N_right = Ntup
        pars[2] = sum(<object>1 << (L-i-1) for i in range(N_right))
        pars[3] = sum(<object>1 << i for i in range(N_right))
        Ns = make_z_basis_template[basis_type,N_type](next_state_pcon_spf,pars,MAX,s,L,zblock,&N[Ns_tot],basis[Ns_tot:])

        if Np_list is not None:
            Np_list[Ns_tot:Ns_tot+Ns] = Ntup
            
        Ns_tot += Ns

    return Ns_tot

def z_basis(int L, int zblock, basis_type[:] pars,N_type[:] N,basis_type[:] basis):
    cdef basis_type s
    cdef npy_intp MAX
    s,MAX = get_state(L)
    return make_z_basis_template[basis_type,N_type](next_state_inc_1,pars,MAX,s,L,zblock,&N[0],basis)




