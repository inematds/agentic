.PHONY: install run clean test lint

install:
	pip install -r requirements.txt

run:
	python agent.py

test:
	python -c "from agent import executar_agente; print(executar_agente('Quanto é 2 + 2?'))"

lint:
	python -m py_compile agent.py && echo "Sem erros de sintaxe"

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null; \
	find . -name "*.pyc" -delete 2>/dev/null; \
	echo "Limpeza concluída"
