package entidades;

public class Pagamento {

    private int idPagamento;
    private int idAluno;
    private double valor;
    private String status;

    public Pagamento() {}

    public Pagamento(int idPagamento, int idAluno, double valor, String status) {
        this.idPagamento = idPagamento;
        this.idAluno = idAluno;
        this.valor = valor;
        this.status = status;
    }

    public int getIdPagamento() {
        return idPagamento;
    }

    public int getIdAluno() {
        return idAluno;
    }

    public double getValor() {
        return valor;
    }

    public String getStatus() {
        return status;
    }

    public void setIdAluno(int idAluno) {
        this.idAluno = idAluno;
    }

    public void setValor(double valor) {
        this.valor = valor;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Pagamento{" +
                "idPagamento=" + idPagamento +
                ", idAluno=" + idAluno +
                ", valor=" + valor +
                ", status='" + status + '\'' +
                '}';
    }
}
