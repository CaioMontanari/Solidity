pragma solidity 0.5.8;

contract FreteAviao {
    
    uint public limiteAviao;
    uint public valorPassagem;
    uint public dataEncerramentoVendas;
    
    address payable public carteiraCompanhiaAerea;
   
    struct passagem {string nomePassageiro; address payable carteiraCliente; address payable carteiraAgencia; bool estornoParaAgencia; bool estornoRealizado;}
    passagem[] public passageiros;
    
    mapping(address => passagem) public passageirosPorAgencia;
    mapping(string => passagem) public mapeamentoReservaPorNome;
    
    bool pousoRealizado;
    bool vooCancelado;
    
    event reservaEfetuada (string aviso, string nomePassageiro, address carteiraAgencia);
    event pousoEfetuadoComSucesso (string aviso, string nomePassageiro, address carteiraAgencia);
    event eventoEstornoRealizado (string nomePassageiro, address carteiraEstorno, uint valorEstorno);
    
    modifier somenteCompanhiaAerea(){
        require (msg.sender == carteiraCompanhiaAerea, "Função exclusiva da Companhia Aérea.");
        _;
    }
    
    constructor (
        uint _limiteAviao,  
        uint _valorPassagem,
        uint _dataEncerramentoVendas,
        address payable _carteiraCompanhiaAerea) public {
        limiteAviao = _limiteAviao;
        valorPassagem = _valorPassagem;
        dataEncerramentoVendas = now + _dataEncerramentoVendas;
        carteiraCompanhiaAerea = _carteiraCompanhiaAerea;
    }
    
    function reserva (string memory nomePassageiro, address payable carteiraCliente, bool estornoParaAgencia) public payable {
        require (now < dataEncerramentoVendas, "Período de compras encerrado.");
        require (msg.value == valorPassagem, "Incorreto o valor da passagem.");
        require (passageiros.length < limiteAviao, "Não há passagens disponíveis.");
        require (!vooCancelado, "Voo cancelado.");
        
        address payable carteiraAgencia = msg.sender;
        
        passagem memory passagemReservada = passagem (nomePassageiro, carteiraCliente, carteiraAgencia, estornoParaAgencia, false);
        passageiros.push(passagemReservada);
        passageirosPorAgencia[carteiraAgencia] = passagemReservada;
        mapeamentoReservaPorNome[nomePassageiro] = passagemReservada;
        
        emit reservaEfetuada ("Reserva efetuada com sucesso.", nomePassageiro, carteiraAgencia);
    } 
        
     function verificarCadeirasSobrando() somenteCompanhiaAerea public view returns (uint) {
        uint cadeirasRestantes = limiteAviao-passageiros.length;
        return cadeirasRestantes;
    }
        
    function pousoSeguro () somenteCompanhiaAerea public {
        require (now > dataEncerramentoVendas, "Voo ainda não saiu.");
        require (!vooCancelado, "Voo cancelado.");
        
        for (uint i=0; i < passageiros.length; i++){
            string memory passageiroQueChegou = passageiros[i].nomePassageiro;
            address carteiraDaAgenciaQueChegou = passageiros[i].carteiraAgencia;
            emit pousoEfetuadoComSucesso ("Pouso realizado com sucesso.", passageiroQueChegou, carteiraDaAgenciaQueChegou);
            
        }
        pousoRealizado = true;
        
        carteiraCompanhiaAerea.transfer(address(this).balance);
    }
    
    function cancelamentoEEstornoDeTodos () somenteCompanhiaAerea public {
        require (!pousoRealizado, "Voo já realizado.");
        for (uint i=0; i < passageiros.length; i++){
            if (passageiros[i].estornoParaAgencia) {
                require (!passageiros[i].estornoRealizado);
                address payable carteiraDeEstorno = passageiros[i].carteiraAgencia;
                carteiraDeEstorno.transfer(valorPassagem);
                emit eventoEstornoRealizado (passageiros[i].nomePassageiro, carteiraDeEstorno, valorPassagem);
            }
            else {
                require (!passageiros[i].estornoRealizado);
                address payable carteiraDeEstorno = passageiros[i].carteiraCliente;
                carteiraDeEstorno.transfer(valorPassagem);
                emit eventoEstornoRealizado (passageiros[i].nomePassageiro, carteiraDeEstorno, valorPassagem);
            } 
            passageiros[i].estornoRealizado = true;
            
        }
        vooCancelado = true;
    }
   
   function comparacaoStrings (string memory a, string memory b) pure public returns (bool) {
        if(bytes(a).length != bytes(b).length) {
        return false;
        } 
        else {
            if (keccak256(bytes(a)) == keccak256(bytes(b))){
                return true;
            }
            else {
                return false;
            }
        }
   }
   
   function estornoIndividual (string memory nomeClienteEstorno) somenteCompanhiaAerea public {
       for (uint i=0; i < passageiros.length; i++){
            if (comparacaoStrings (nomeClienteEstorno, passageiros[i].nomePassageiro)) {
                if (passageiros[i].estornoParaAgencia) {
                    require (!passageiros[i].estornoRealizado);
                    address payable carteiraDeEstorno = passageiros[i].carteiraAgencia;
                    carteiraDeEstorno.transfer(valorPassagem);
                    emit eventoEstornoRealizado (passageiros[i].nomePassageiro, carteiraDeEstorno, valorPassagem);
                }
                else {
                    require (!passageiros[i].estornoRealizado);
                    address payable carteiraDeEstorno = passageiros[i].carteiraCliente;
                    carteiraDeEstorno.transfer(valorPassagem);
                    emit eventoEstornoRealizado (passageiros[i].nomePassageiro, carteiraDeEstorno, valorPassagem);
                }
                passageiros[i].estornoRealizado = true; 
            }    
        }
   }  
}
