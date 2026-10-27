/**
 * FIT UP PRO — Client-Side Application Logic
 * Full CRUD, Authentication, Live Search Filtering, and Dashboard Analytics
 */

document.addEventListener('DOMContentLoaded', () => {

    // =========================================================================
    // STATE & CACHE
    // =========================================================================
    let cachedAlunos = [];
    let cachedInstrutores = [];
    let cachedPlanos = [];
    let cachedPagamentos = [];
    let cachedMatriculas = [];
    let activePage = 'dashboard';

    const AUTH_STORAGE_KEY = 'fitup_auth_session';

    // Base URL for API — empty string for same-origin (local dev / Railway).
    // When deployed to Vercel, set window.FITUP_API_URL or use Vercel env vars.
    const API_BASE_URL = window.FITUP_API_URL || '';

    // =========================================================================
    // AUTHENTICATION LOGIC
    // =========================================================================
    const authContainer = document.getElementById('auth-container');
    const formLogin = document.getElementById('form-login');
    const inputEmail = document.getElementById('login-email');
    const inputSenha = document.getElementById('login-senha');
    const btnToggleSenha = document.getElementById('btn-toggle-senha');
    const iconToggleSenha = document.getElementById('icon-toggle-senha');
    const btnFillDemo = document.getElementById('btn-fill-demo');
    const authErrorBox = document.getElementById('auth-error-box');
    const authErrorMsg = document.getElementById('auth-error-msg');
    const btnLogoutSidebar = document.getElementById('btn-logout-sidebar');

    function checkAuthSession() {
        const session = localStorage.getItem(AUTH_STORAGE_KEY);
        if (session) {
            try {
                const user = JSON.parse(session);
                document.getElementById('sidebar-user-name').textContent = user.name || 'Administrador';
                document.getElementById('sidebar-user-avatar').textContent = (user.name ? user.name.slice(0, 2).toUpperCase() : 'AD');
                authContainer.classList.add('hidden');
                loadAllData();
            } catch {
                localStorage.removeItem(AUTH_STORAGE_KEY);
                authContainer.classList.remove('hidden');
            }
        } else {
            authContainer.classList.remove('hidden');
        }
    }

    // Toggle Password Visibility
    if (btnToggleSenha) {
        btnToggleSenha.addEventListener('click', () => {
            const isPassword = inputSenha.type === 'password';
            inputSenha.type = isPassword ? 'text' : 'password';
            iconToggleSenha.className = isPassword ? 'ph ph-eye-slash' : 'ph ph-eye';
        });
    }

    // Quick Fill Demo Credentials
    if (btnFillDemo) {
        btnFillDemo.addEventListener('click', () => {
            inputEmail.value = 'admin@fitup.com';
            inputSenha.value = 'Senha@123';
            if (authErrorBox) authErrorBox.style.display = 'none';
            showToast('Credenciais de teste preenchidas!', 'info');
        });
    }

    // Submit Login Form
    if (formLogin) {
        formLogin.addEventListener('submit', async (e) => {
            e.preventDefault();
            authErrorBox.style.display = 'none';

            const email = inputEmail.value.trim();
            const senha = inputSenha.value;

            try {
                const res = await fetch(API_BASE_URL + '/api/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email, senha })
                });

                const data = await res.json();

                if (res.ok && data.status === 'sucesso') {
                    const sessionData = {
                        email,
                        name: 'Administrador FIT UP',
                        token: data.token || 'tok_admin_fitup_2026',
                        loginTime: new Date().toISOString()
                    };
                    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(sessionData));
                    showToast('Login realizado com sucesso! Bem-vindo.', 'success');
                    authContainer.classList.add('hidden');
                    loadAllData();
                } else {
                    authErrorMsg.textContent = data.erro || 'E-mail ou senha incorretos.';
                    authErrorBox.style.display = 'flex';
                }
            } catch (err) {
                authErrorMsg.textContent = 'Erro de conexão com o servidor. Tente novamente.';
                authErrorBox.style.display = 'flex';
            }
        });
    }

    // Logout
    if (btnLogoutSidebar) {
        btnLogoutSidebar.addEventListener('click', () => {
            if (confirm('Deseja realmente encerrar a sessão?')) {
                localStorage.removeItem(AUTH_STORAGE_KEY);
                authContainer.classList.remove('hidden');
                showToast('Sessão encerrada com sucesso.', 'info');
            }
        });
    }

    // =========================================================================
    // NAVIGATION & PAGE TITLES
    // =========================================================================
    const pageTitles = {
        dashboard: { title: 'Dashboard Geral', subtitle: 'Indicadores, alunos recentes e fluxo financeiro' },
        alunos: { title: 'Gestão de Alunos', subtitle: 'Cadastro biométrico, matrícula e acompanhamento físico' },
        instrutores: { title: 'Equipe de Instrutores', subtitle: 'Profissionais e especialidades ativas' },
        planos: { title: 'Planos e Modalidades', subtitle: 'Valores mensais e assinaturas disponíveis' },
        pagamentos: { title: 'Controle de Pagamentos', subtitle: 'Histórico de mensalidades e status' }
    };

    window.navigateToPage = function(pageName) {
        activePage = pageName;
        document.querySelectorAll('.sidebar-nav-item').forEach(l => l.classList.remove('active'));
        const navItem = document.querySelector(`.sidebar-nav-item[data-page="${pageName}"]`);
        if (navItem) navItem.classList.add('active');

        document.querySelectorAll('.page-view').forEach(p => p.classList.remove('active-view'));
        const targetPage = document.getElementById('page-' + pageName);
        if (targetPage) targetPage.classList.add('active-view');

        if (pageTitles[pageName]) {
            document.getElementById('current-page-title').textContent = pageTitles[pageName].title;
            document.getElementById('current-page-subtitle').textContent = pageTitles[pageName].subtitle;
        }

        loadPageData(pageName);
    };

    document.querySelectorAll('.sidebar-nav-item').forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const target = link.dataset.page;
            if (target) navigateToPage(target);
        });
    });

    // =========================================================================
    // CLOCK & DATE IN TOPBAR
    // =========================================================================
    function updateClock() {
        const clockEl = document.getElementById('live-datetime-clock');
        if (!clockEl) return;
        const now = new Date();
        const options = { weekday: 'short', day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' };
        clockEl.innerHTML = `<i class="ph ph-clock"></i> ${now.toLocaleDateString('pt-BR', options).toUpperCase()}`;
    }
    setInterval(updateClock, 1000);
    updateClock();

    // =========================================================================
    // MODALS HANDLING
    // =========================================================================
    document.querySelectorAll('[data-modal]').forEach(btn => {
        btn.addEventListener('click', () => {
            const modalId = btn.dataset.modal;
            const modal = document.getElementById(modalId);
            if (!modal) return;
            const form = modal.querySelector('form');
            if (form) form.reset();
            const hiddenId = form ? form.querySelector('input[type="hidden"]') : null;
            if (hiddenId) hiddenId.value = '';

            if (modalId === 'modal-aluno') {
                document.getElementById('modal-aluno-title').innerHTML = '<i class="ph-bold ph-user-plus"></i> Cadastrar Aluno';
                document.getElementById('btn-submit-aluno').innerHTML = '<i class="ph-bold ph-check"></i> Cadastrar Aluno';
                populatePlanoSelect();
            }
            if (modalId === 'modal-instrutor') {
                document.getElementById('modal-instrutor-title').innerHTML = '<i class="ph-bold ph-chalkboard-teacher"></i> Cadastrar Instrutor';
                document.getElementById('btn-submit-instrutor').innerHTML = '<i class="ph-bold ph-check"></i> Cadastrar Instrutor';
            }
            if (modalId === 'modal-plano') {
                document.getElementById('modal-plano-title').innerHTML = '<i class="ph-bold ph-clipboard-text"></i> Cadastrar Plano';
                document.getElementById('btn-submit-plano').innerHTML = '<i class="ph-bold ph-check"></i> Cadastrar Plano';
            }
            if (modalId === 'modal-pagamento') {
                document.getElementById('modal-pagamento-title').innerHTML = '<i class="ph-bold ph-receipt"></i> Lançar Pagamento';
                document.getElementById('btn-submit-pagamento').innerHTML = '<i class="ph-bold ph-check"></i> Registrar Pagamento';
                populateAlunoSelect('select-aluno-pagamento');
                document.getElementById('pagamento-valor').value = '';
                document.getElementById('form-pagamento').idPagamento.value = '';
            }
            modal.classList.add('active');
        });
    });

    document.querySelectorAll('.close-btn').forEach(b => {
        b.addEventListener('click', () => {
            const overlay = b.closest('.modal-backdrop');
            if (overlay) overlay.classList.remove('active');
        });
    });

    document.querySelectorAll('.modal-backdrop').forEach(o => {
        o.addEventListener('click', (e) => {
            if (e.target === o) o.classList.remove('active');
        });
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeAllModals();
    });

    function closeAllModals() {
        document.querySelectorAll('.modal-backdrop').forEach(m => m.classList.remove('active'));
    }

    // =========================================================================
    // TOAST NOTIFICATIONS
    // =========================================================================
    function showToast(msg, type = 'success') {
        const container = document.getElementById('toast-container');
        if (!container) return;
        const toast = document.createElement('div');
        toast.className = `toast-pill ${type}`;
        
        let iconHtml = '<i class="ph-fill ph-check-circle"></i>';
        if (type === 'error') iconHtml = '<i class="ph-fill ph-x-circle"></i>';
        if (type === 'info') iconHtml = '<i class="ph-fill ph-lightning"></i>';

        toast.innerHTML = `${iconHtml}<span>${msg}</span>`;
        container.appendChild(toast);

        setTimeout(() => toast.classList.add('show'), 10);
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => toast.remove(), 350);
        }, 3500);
    }

    // =========================================================================
    // INPUT MASKS & AUTO-VALUES
    // =========================================================================
    const maskCpf = (val) => {
        if (!val) return '';
        return val.replace(/\D/g, '')
            .replace(/(\d{3})(\d)/, '$1.$2')
            .replace(/(\d{3})(\d)/, '$1.$2')
            .replace(/(\d{3})(\d{1,2})/, '$1-$2')
            .replace(/(-\d{2})\d+?$/, '$1');
    };

    const maskPhone = (val) => {
        if (!val) return '';
        return val.replace(/\D/g, '')
            .replace(/(\d{2})(\d)/, '($1) $2')
            .replace(/(\d{5})(\d)/, '$1-$2')
            .replace(/(-\d{4})\d+?$/, '$1');
    };

    document.querySelectorAll('input[placeholder*="000.000.000-00"]').forEach(input => {
        input.addEventListener('input', (e) => { e.target.value = maskCpf(e.target.value); });
    });

    document.querySelectorAll('input[placeholder*="(11) 99999-9999"], input[placeholder*="(00) 00000-0000"], input[placeholder*="(11) 98888-8888"]').forEach(input => {
        input.addEventListener('input', (e) => { e.target.value = maskPhone(e.target.value); });
    });

    // Auto calculate price on student selection in Payment modal
    const selAlunoPag = document.getElementById('select-aluno-pagamento');
    if (selAlunoPag) {
        selAlunoPag.addEventListener('change', async (e) => {
            const idAluno = parseInt(e.target.value);
            const valorInput = document.getElementById('pagamento-valor');
            if (!idAluno) { valorInput.value = ''; return; }
            
            const [matriculas, alunos, planos] = await Promise.all([
                fetchData('/api/matriculas'), fetchData('/api/alunos'), fetchData('/api/planos')
            ]);
            const aluno = alunos.find(a => a.id === idAluno);
            const mat = matriculas.find(m => m.idAluno === idAluno || (aluno && m.nomeAluno === aluno.nome));
            if (mat) {
                const plano = planos.find(p => p.nome === mat.nomePlano);
                if (plano) { valorInput.value = plano.valor.toFixed(2); return; }
            }
            valorInput.value = '';
        });
    }

    // =========================================================================
    // VALIDATIONS
    // =========================================================================
    function validarCPF(cpf) {
        if (!cpf) return false;
        const limpo = cpf.replace(/\D/g, '');
        return limpo.length === 11;
    }

    function validarEmail(email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }

    function getInitials(name) {
        if (!name) return '??';
        const parts = name.trim().split(' ');
        if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    // =========================================================================
    // FORMS SUBMISSION (CRUD)
    // =========================================================================
    
    // Aluno Form
    document.getElementById('form-aluno').addEventListener('submit', async (e) => {
        e.preventDefault();
        const form = e.target;
        const nome = form.nome.value.trim();
        const cpf = form.cpf.value.trim();
        const email = form.email.value.trim();
        const telefone = form.telefone.value.trim();
        const endereco = form.endereco.value.trim();
        const dataNascimento = form.dataNascimento.value;
        const peso = parseFloat(form.peso.value) || 0;
        const altura = parseFloat(form.altura.value) || 0;
        const idPlano = form.idPlano.value;

        if (nome.length < 3) {
            showToast('O nome deve conter pelo menos 3 caracteres.', 'error');
            return;
        }
        if (!validarCPF(cpf)) {
            showToast('CPF inválido! Preencha os 11 dígitos.', 'error');
            return;
        }
        if (!validarEmail(email)) {
            showToast('E-mail com formato inválido!', 'error');
            return;
        }
        if (new Date(dataNascimento) > new Date()) {
            showToast('A data de nascimento não pode ser no futuro.', 'error');
            return;
        }

        const id = form.id.value;
        const data = {
            nome, cpf, email,
            telefone: telefone || 'Não informado',
            endereco: endereco || 'Não informado',
            dataNascimento, peso, altura,
            idPlano: idPlano ? parseInt(idPlano) : 0
        };

        let ok;
        if (id) {
            data.ativo = true;
            ok = await putData('/api/alunos/' + id, data);
            if (ok) showToast('Aluno atualizado com sucesso!', 'success');
        } else {
            ok = await postData('/api/alunos', data);
            if (ok) showToast('Aluno cadastrado com sucesso!', 'success');
        }
        if (ok) {
            form.reset();
            closeAllModals();
            loadAllData();
        }
    });

    // Instrutor Form
    document.getElementById('form-instrutor').addEventListener('submit', async (e) => {
        e.preventDefault();
        const form = e.target;
        const nome = form.nome.value.trim();
        const cpf = form.cpf.value.trim();
        const email = form.email.value.trim();
        const telefone = form.telefone.value.trim();
        const especialidade = form.especialidade.value.trim();

        if (nome.length < 3) {
            showToast('O nome do instrutor deve ter no mínimo 3 caracteres.', 'error');
            return;
        }
        if (!validarCPF(cpf)) {
            showToast('CPF inválido para o instrutor.', 'error');
            return;
        }
        if (email && !validarEmail(email)) {
            showToast('E-mail inválido.', 'error');
            return;
        }
        if (!especialidade) {
            showToast('Informe a especialidade do instrutor.', 'error');
            return;
        }

        const id = form.idInstrutor.value;
        const data = { nome, cpf, email: email || 'Não informado', telefone: telefone || 'Não informado', especialidade };

        let ok;
        if (id) {
            ok = await putData('/api/instrutores/' + id, data);
            if (ok) showToast('Instrutor atualizado!', 'success');
        } else {
            ok = await postData('/api/instrutores', data);
            if (ok) showToast('Instrutor cadastrado!', 'success');
        }
        if (ok) {
            form.reset();
            closeAllModals();
            loadAllData();
        }
    });

    // Plano Form
    document.getElementById('form-plano').addEventListener('submit', async (e) => {
        e.preventDefault();
        const form = e.target;
        const nome = form.nome.value.trim();
        const valor = parseFloat(form.valor.value) || 0;

        if (!nome) {
            showToast('O nome do plano é obrigatório.', 'error');
            return;
        }
        if (valor <= 0) {
            showToast('O valor do plano deve ser maior que zero.', 'error');
            return;
        }

        const id = form.id.value;
        const data = { nome, valor };

        let ok;
        if (id) {
            ok = await putData('/api/planos/' + id, data);
            if (ok) showToast('Plano atualizado!', 'success');
        } else {
            ok = await postData('/api/planos', data);
            if (ok) showToast('Plano cadastrado com sucesso!', 'success');
        }
        if (ok) {
            form.reset();
            closeAllModals();
            loadAllData();
        }
    });

    // Pagamento Form
    document.getElementById('form-pagamento').addEventListener('submit', async (e) => {
        e.preventDefault();
        const form = e.target;
        const idAluno = form.idAluno.value;
        const valor = parseFloat(form.valor.value) || 0;
        const status = form.status.value;

        if (!idAluno) {
            showToast('Selecione o aluno para o pagamento.', 'error');
            return;
        }
        if (valor <= 0) {
            showToast('Informe um valor válido para o pagamento.', 'error');
            return;
        }

        const id = form.idPagamento.value;
        const data = { idAluno: parseInt(idAluno), valor, status };

        let ok;
        if (id) {
            ok = await putData('/api/pagamentos/' + id, data);
            if (ok) showToast('Pagamento atualizado com sucesso!', 'success');
        } else {
            ok = await postData('/api/pagamentos', data);
            if (ok) showToast('Pagamento registrado com sucesso!', 'success');
        }
        if (ok) {
            form.reset();
            closeAllModals();
            loadAllData();
        }
    });

    // =========================================================================
    // GLOBAL SAFE EDIT & DELETE ACTIONS (LOOKUP BY ID)
    // =========================================================================
    window.editAluno = async function(id) {
        const a = cachedAlunos.find(x => x.id === id);
        if (!a) return;
        const form = document.getElementById('form-aluno');
        form.id.value = a.id;
        form.nome.value = a.nome;
        form.cpf.value = a.cpf;
        form.email.value = a.email;
        form.telefone.value = a.telefone;
        form.endereco.value = a.endereco;
        form.dataNascimento.value = a.dataNascimento;
        form.peso.value = a.peso || '';
        form.altura.value = a.altura || '';
        document.getElementById('modal-aluno-title').innerHTML = '<i class="ph-bold ph-pencil-simple"></i> Editar Aluno';
        document.getElementById('btn-submit-aluno').innerHTML = '<i class="ph-bold ph-check"></i> Salvar Alterações';
        
        await populatePlanoSelect();
        const mat = cachedMatriculas.find(m => m.idAluno === id || m.nomeAluno === a.nome);
        if (mat) {
            const plano = cachedPlanos.find(p => p.nome === mat.nomePlano);
            if (plano) document.getElementById('select-plano-aluno').value = plano.id;
        }
        document.getElementById('modal-aluno').classList.add('active');
    };

    window.editInstrutor = function(id) {
        const i = cachedInstrutores.find(x => x.idInstrutor === id);
        if (!i) return;
        const form = document.getElementById('form-instrutor');
        form.idInstrutor.value = i.idInstrutor;
        form.nome.value = i.nome;
        form.cpf.value = i.cpf;
        form.email.value = (i.email === 'Não informado' ? '' : i.email);
        form.telefone.value = (i.telefone === 'Não informado' ? '' : i.telefone);
        form.especialidade.value = i.especialidade;
        document.getElementById('modal-instrutor-title').innerHTML = '<i class="ph-bold ph-pencil-simple"></i> Editar Instrutor';
        document.getElementById('btn-submit-instrutor').innerHTML = '<i class="ph-bold ph-check"></i> Salvar Alterações';
        document.getElementById('modal-instrutor').classList.add('active');
    };

    window.editPlano = function(id) {
        const p = cachedPlanos.find(x => x.id === id);
        if (!p) return;
        const form = document.getElementById('form-plano');
        form.id.value = p.id;
        form.nome.value = p.nome;
        form.valor.value = p.valor;
        document.getElementById('modal-plano-title').innerHTML = '<i class="ph-bold ph-pencil-simple"></i> Editar Plano';
        document.getElementById('btn-submit-plano').innerHTML = '<i class="ph-bold ph-check"></i> Salvar Alterações';
        document.getElementById('modal-plano').classList.add('active');
    };

    window.editPagamento = async function(id) {
        const p = cachedPagamentos.find(x => x.idPagamento === id);
        if (!p) return;
        const form = document.getElementById('form-pagamento');
        form.idPagamento.value = p.idPagamento;
        await populateAlunoSelect('select-aluno-pagamento');
        const aluno = cachedAlunos.find(a => a.nome === p.nomeAluno);
        if (aluno) {
            form.idAluno.value = aluno.id;
        }
        form.valor.value = p.valor || '';
        form.status.value = p.status || 'Pago';
        document.getElementById('modal-pagamento-title').innerHTML = '<i class="ph-bold ph-pencil-simple"></i> Editar Pagamento';
        document.getElementById('btn-submit-pagamento').innerHTML = '<i class="ph-bold ph-check"></i> Salvar Alterações';
        document.getElementById('modal-pagamento').classList.add('active');
    };

    window.deleteItem = async function(entity, id, label) {
        const desc = label ? label : 'este registro';
        if (!confirm(`Tem certeza que deseja apagar ${desc}?`)) return;
        const ok = await deleteData('/api/' + entity + '/' + id);
        if (ok) {
            showToast(`${desc} excluído com sucesso!`, 'success');
            loadAllData();
        }
    };

    // =========================================================================
    // DATA RENDERING
    // =========================================================================
    async function loadAllData() {
        const [alunos, instrutores, planos, pagamentos, matriculas] = await Promise.all([
            fetchData('/api/alunos'),
            fetchData('/api/instrutores'),
            fetchData('/api/planos'),
            fetchData('/api/pagamentos'),
            fetchData('/api/matriculas')
        ]);

        cachedAlunos = alunos;
        cachedInstrutores = instrutores;
        cachedPlanos = planos;
        cachedPagamentos = pagamentos;
        cachedMatriculas = matriculas;

        // Update Nav badges
        document.getElementById('badge-nav-alunos').textContent = alunos.length;
        document.getElementById('badge-nav-instrutores').textContent = instrutores.length;
        document.getElementById('badge-nav-planos').textContent = planos.length;
        document.getElementById('badge-nav-pagamentos').textContent = pagamentos.length;

        // Render Views
        renderDashboard();
        renderAlunos(cachedAlunos);
        renderInstrutores(cachedInstrutores);
        renderPlanos(cachedPlanos);
        renderPagamentos(cachedPagamentos);
    }

    function renderDashboard() {
        document.getElementById('stat-alunos').textContent = cachedAlunos.length;
        document.getElementById('stat-instrutores').textContent = cachedInstrutores.length;
        document.getElementById('stat-planos').textContent = cachedPlanos.length;
        document.getElementById('stat-pagamentos').textContent = cachedPagamentos.length;

        const matMap = {};
        cachedMatriculas.forEach(m => matMap[m.nomeAluno] = m.nomePlano);

        const tbody = document.getElementById('dashboard-alunos-table');
        tbody.innerHTML = '';
        const recentes = cachedAlunos.slice(-5).reverse();

        if (!recentes.length) {
            tbody.innerHTML = `
                <tr class="empty-craft-row">
                    <td colspan="5">Nenhum aluno registrado ainda.</td>
                </tr>`;
            return;
        }

        recentes.forEach(a => {
            const plano = matMap[a.nome] || '<span style="color:var(--text-muted)">Sem plano</span>';
            const initials = getInitials(a.nome);
            tbody.innerHTML += `
                <tr>
                    <td>
                        <div class="user-identity-cell">
                            <div class="user-monogram-stamp">${initials}</div>
                            <div class="user-identity-info">
                                <strong>${a.nome}</strong>
                                <span>ID #${a.id}</span>
                            </div>
                        </div>
                    </td>
                    <td><span style="font-family:var(--font-mono); font-size:12px;">${a.cpf}</span></td>
                    <td>${a.email || '-'}</td>
                    <td><strong style="color:var(--volt);">${plano}</strong></td>
                    <td>
                        <span class="status-pill ${a.ativo ? 'active' : 'inactive'}">
                            ${a.ativo ? 'ATIVO' : 'INATIVO'}
                        </span>
                    </td>
                </tr>`;
        });
    }

    function renderAlunos(alunosList) {
        const matMap = {};
        cachedMatriculas.forEach(m => matMap[m.nomeAluno] = m.nomePlano);
        const tbody = document.getElementById('alunos-table');
        tbody.innerHTML = '';

        if (!alunosList.length) {
            tbody.innerHTML = `
                <tr class="empty-craft-row">
                    <td colspan="8">Nenhum aluno encontrado.</td>
                </tr>`;
            return;
        }

        alunosList.forEach(a => {
            const plano = matMap[a.nome] || '<span style="color:var(--text-muted)">Sem plano</span>';
            let imcBadge = '<span style="color:var(--text-muted)">—</span>';

            if (a.peso > 0 && a.altura > 0) {
                const imc = a.peso / (a.altura * a.altura);
                let cls = 'normal';
                let label = 'Normal';
                if (imc < 18.5) { cls = 'baixo'; label = 'Baixo'; }
                else if (imc >= 25 && imc < 30) { cls = 'sobrepeso'; label = 'Sobrepeso'; }
                else if (imc >= 30) { cls = 'obeso'; label = 'Obesidade'; }
                imcBadge = `<span class="imc-chip ${cls}" title="IMC: ${imc.toFixed(2)}">${imc.toFixed(1)} [${label.toUpperCase()}]</span>`;
            }

            const initials = getInitials(a.nome);
            tbody.innerHTML += `
                <tr>
                    <td><span style="font-family:var(--font-mono); color:var(--text-muted);">#${a.id}</span></td>
                    <td>
                        <div class="user-identity-cell">
                            <div class="user-monogram-stamp">${initials}</div>
                            <div class="user-identity-info">
                                <strong>${a.nome}</strong>
                                <span>${a.telefone || 'Sem telefone'}</span>
                            </div>
                        </div>
                    </td>
                    <td><span style="font-family:var(--font-mono); font-size:12px;">${a.cpf}</span></td>
                    <td>${a.email || '-'}</td>
                    <td><strong style="color:var(--volt);">${plano}</strong></td>
                    <td>${imcBadge}</td>
                    <td>
                        <span class="status-pill ${a.ativo ? 'active' : 'inactive'}">
                            ${a.ativo ? 'ATIVO' : 'INATIVO'}
                        </span>
                    </td>
                    <td style="text-align: right;">
                        <div class="row-actions" style="justify-content: flex-end;">
                            <button class="btn-action-tool edit" onclick="editAluno(${a.id})" title="Editar"><i class="ph ph-pencil-simple"></i></button>
                            <button class="btn-action-tool delete" onclick="deleteItem('alunos', ${a.id}, '${a.nome.replace(/'/g, "\\'")}')" title="Apagar"><i class="ph ph-trash"></i></button>
                        </div>
                    </td>
                </tr>`;
        });
    }

    function renderInstrutores(instrutoresList) {
        const tbody = document.getElementById('instrutores-table');
        tbody.innerHTML = '';

        if (!instrutoresList.length) {
            tbody.innerHTML = `
                <tr class="empty-craft-row">
                    <td colspan="6">Nenhum instrutor encontrado.</td>
                </tr>`;
            return;
        }

        instrutoresList.forEach(i => {
            const initials = getInitials(i.nome);
            tbody.innerHTML += `
                <tr>
                    <td><span style="font-family:var(--font-mono); color:var(--text-muted);">#${i.idInstrutor}</span></td>
                    <td>
                        <div class="user-identity-cell">
                            <div class="user-monogram-stamp instructor">${initials}</div>
                            <div class="user-identity-info">
                                <strong>${i.nome}</strong>
                                <span>${i.telefone || 'Sem telefone'}</span>
                            </div>
                        </div>
                    </td>
                    <td><span style="font-family:var(--font-mono); font-size:12px;">${i.cpf || '-'}</span></td>
                    <td>${i.email || '-'}</td>
                    <td><span style="font-family:var(--font-heading); font-weight:700; color:var(--cyan);">${i.especialidade}</span></td>
                    <td style="text-align: right;">
                        <div class="row-actions" style="justify-content: flex-end;">
                            <button class="btn-action-tool edit" onclick="editInstrutor(${i.idInstrutor})" title="Editar"><i class="ph ph-pencil-simple"></i></button>
                            <button class="btn-action-tool delete" onclick="deleteItem('instrutores', ${i.idInstrutor}, '${i.nome.replace(/'/g, "\\'")}')" title="Apagar"><i class="ph ph-trash"></i></button>
                        </div>
                    </td>
                </tr>`;
        });
    }

    function renderPlanos(planosList) {
        const tbody = document.getElementById('planos-table');
        tbody.innerHTML = '';

        if (!planosList.length) {
            tbody.innerHTML = `
                <tr class="empty-craft-row">
                    <td colspan="4">Nenhum plano cadastrado.</td>
                </tr>`;
            return;
        }

        planosList.forEach(p => {
            tbody.innerHTML += `
                <tr>
                    <td><span style="font-family:var(--font-mono); color:var(--text-muted);">#${p.id}</span></td>
                    <td><strong>${p.nome}</strong></td>
                    <td><span style="font-family:var(--font-display); font-size:16px; font-weight:900; color:var(--emerald);">R$ ${p.valor.toFixed(2)}</span> <span style="font-family:var(--font-mono); font-size:11px; color:var(--text-muted);">/ MÊS</span></td>
                    <td style="text-align: right;">
                        <div class="row-actions" style="justify-content: flex-end;">
                            <button class="btn-action-tool edit" onclick="editPlano(${p.id})" title="Editar"><i class="ph ph-pencil-simple"></i></button>
                            <button class="btn-action-tool delete" onclick="deleteItem('planos', ${p.id}, '${p.nome.replace(/'/g, "\\'")}')" title="Apagar"><i class="ph ph-trash"></i></button>
                        </div>
                    </td>
                </tr>`;
        });
    }

    function renderPagamentos(pagamentosList) {
        const tbody = document.getElementById('pagamentos-table');
        tbody.innerHTML = '';

        if (!pagamentosList.length) {
            tbody.innerHTML = `
                <tr class="empty-craft-row">
                    <td colspan="5">Nenhum pagamento registrado.</td>
                </tr>`;
            return;
        }

        pagamentosList.forEach(p => {
            const initials = getInitials(p.nomeAluno);
            tbody.innerHTML += `
                <tr>
                    <td><span style="font-family:var(--font-mono); color:var(--text-muted);">#${p.idPagamento}</span></td>
                    <td>
                        <div class="user-identity-cell">
                            <div class="user-monogram-stamp payment">${initials}</div>
                            <div class="user-identity-info">
                                <strong>${p.nomeAluno}</strong>
                                <span>Mensalidade</span>
                            </div>
                        </div>
                    </td>
                    <td><strong style="color:var(--text-primary); font-family:var(--font-mono); font-size:14px;">R$ ${p.valor.toFixed(2)}</strong></td>
                    <td>
                        <span class="status-pill ${p.status}">
                            ${p.status.toUpperCase()}
                        </span>
                    </td>
                    <td style="text-align: right;">
                        <div class="row-actions" style="justify-content: flex-end;">
                            <button class="btn-action-tool edit" onclick="editPagamento(${p.idPagamento})" title="Editar"><i class="ph ph-pencil-simple"></i></button>
                            <button class="btn-action-tool delete" onclick="deleteItem('pagamentos', ${p.idPagamento}, 'Pagamento #${p.idPagamento}')" title="Apagar"><i class="ph ph-trash"></i></button>
                        </div>
                    </td>
                </tr>`;
        });
    }

    // =========================================================================
    // SEARCH & FILTER LISTENERS
    // =========================================================================
    
    // Global Search Bar
    const globalSearch = document.getElementById('global-search-input');
    if (globalSearch) {
        globalSearch.addEventListener('input', (e) => {
            const term = e.target.value.toLowerCase().trim();
            if (!term) {
                renderAlunos(cachedAlunos);
                renderInstrutores(cachedInstrutores);
                renderPlanos(cachedPlanos);
                renderPagamentos(cachedPagamentos);
                return;
            }
            if (activePage === 'alunos') {
                const filtered = cachedAlunos.filter(a => a.nome.toLowerCase().includes(term) || a.cpf.includes(term) || (a.email && a.email.toLowerCase().includes(term)));
                renderAlunos(filtered);
            } else if (activePage === 'instrutores') {
                const filtered = cachedInstrutores.filter(i => i.nome.toLowerCase().includes(term) || i.especialidade.toLowerCase().includes(term));
                renderInstrutores(filtered);
            } else if (activePage === 'planos') {
                const filtered = cachedPlanos.filter(p => p.nome.toLowerCase().includes(term));
                renderPlanos(filtered);
            } else if (activePage === 'pagamentos') {
                const filtered = cachedPagamentos.filter(p => p.nomeAluno.toLowerCase().includes(term) || p.status.toLowerCase().includes(term));
                renderPagamentos(filtered);
            }
        });
    }

    // Specific Page Filters
    const searchAlunosFilter = document.getElementById('search-alunos-filter');
    if (searchAlunosFilter) {
        searchAlunosFilter.addEventListener('input', (e) => {
            const term = e.target.value.toLowerCase().trim();
            const filtered = cachedAlunos.filter(a => a.nome.toLowerCase().includes(term) || a.cpf.includes(term) || (a.email && a.email.toLowerCase().includes(term)));
            renderAlunos(filtered);
        });
    }

    const searchInstrutoresFilter = document.getElementById('search-instrutores-filter');
    if (searchInstrutoresFilter) {
        searchInstrutoresFilter.addEventListener('input', (e) => {
            const term = e.target.value.toLowerCase().trim();
            const filtered = cachedInstrutores.filter(i => i.nome.toLowerCase().includes(term) || i.especialidade.toLowerCase().includes(term));
            renderInstrutores(filtered);
        });
    }

    const searchPlanosFilter = document.getElementById('search-planos-filter');
    if (searchPlanosFilter) {
        searchPlanosFilter.addEventListener('input', (e) => {
            const term = e.target.value.toLowerCase().trim();
            const filtered = cachedPlanos.filter(p => p.nome.toLowerCase().includes(term));
            renderPlanos(filtered);
        });
    }

    const searchPagamentosFilter = document.getElementById('search-pagamentos-filter');
    if (searchPagamentosFilter) {
        searchPagamentosFilter.addEventListener('input', (e) => {
            const term = e.target.value.toLowerCase().trim();
            const filtered = cachedPagamentos.filter(p => p.nomeAluno.toLowerCase().includes(term) || p.status.toLowerCase().includes(term));
            renderPagamentos(filtered);
        });
    }

    // =========================================================================
    // SELECT POPULATION HELPERS
    // =========================================================================
    async function populatePlanoSelect() {
        const planos = await fetchData('/api/planos');
        const s = document.getElementById('select-plano-aluno');
        s.innerHTML = '<option value="">Sem plano</option>';
        planos.forEach(p => s.innerHTML += `<option value="${p.id}">${p.nome} — R$ ${p.valor.toFixed(2)}/mês</option>`);
    }

    async function populateAlunoSelect(selectId) {
        const alunos = await fetchData('/api/alunos');
        const s = document.getElementById(selectId);
        s.innerHTML = '<option value="">Selecione o aluno</option>';
        alunos.forEach(a => s.innerHTML += `<option value="${a.id}">${a.nome} (CPF: ${a.cpf})</option>`);
    }

    // =========================================================================
    // HTTP FETCH HELPERS
    // =========================================================================
    async function fetchData(url) {
        try {
            const r = await fetch(API_BASE_URL + url);
            if (!r.ok) throw 0;
            return await r.json();
        } catch {
            return [];
        }
    }

    async function postData(url, data) {
        try {
            const r = await fetch(API_BASE_URL + url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            return r.ok;
        } catch {
            showToast('Falha de conexão com a API.', 'error');
            return false;
        }
    }

    async function putData(url, data) {
        try {
            const r = await fetch(API_BASE_URL + url, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            return r.ok;
        } catch {
            showToast('Falha de conexão com a API.', 'error');
            return false;
        }
    }

    async function deleteData(url) {
        try {
            const r = await fetch(API_BASE_URL + url, { method: 'DELETE' });
            return r.ok;
        } catch {
            showToast('Falha de conexão com a API.', 'error');
            return false;
        }
    }

    function loadPageData(page) {
        if (page === 'dashboard') renderDashboard();
        else if (page === 'alunos') renderAlunos(cachedAlunos);
        else if (page === 'instrutores') renderInstrutores(cachedInstrutores);
        else if (page === 'planos') renderPlanos(cachedPlanos);
        else if (page === 'pagamentos') renderPagamentos(cachedPagamentos);
    }

    // =========================================================================
    // INITIALIZATION
    // =========================================================================
    checkAuthSession();
});
