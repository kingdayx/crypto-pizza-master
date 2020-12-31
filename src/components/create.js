import React from 'react'
import '../App.css'
import createYummyPizza from '../functions/createPizza'
import { generatePizzaImage } from '../functions/pizza'

export function Create(props) {
  const handleSubmit = (event) => {
    event.preventDefault()
    const accounts = props.accounts
    const value = props.gas
    createYummyPizza(value, accounts)
  }
  const onSubmit = (event) => {
    event.preventDefault()
  }
  const toppings = generatePizzaImage(props.gas)
  return (
    <div id="create-tab-content" className="tabcontent">
      <header>
        <hr />
      </header>

      <h2>Create new CryptoPizza</h2>

      <div className="pizza-container">
        <img
          className="pizza-frame"
          alt="pizza frame"
          src="https://studio.ethereum.org/static/img/cryptopizza/container.jpg"
        />
        <img
          alt="pizza"
          src="https://studio.ethereum.org/static/img/cryptopizza/corpus.png"
        />

        <div id="pizza-ingredients-container" className="ingredients">
          {toppings.map((topping, id) => (
            <div>{topping}</div>
          ))}
        </div>
      </div>

      <div>
        <form className="input-container" onSubmit={onSubmit}>
          <input
            type="text"
            id="create-input"
            value={props.gas}
            placeholder="Enter name..."
            maxLength="20"
            onChange={props.handleChange}
          />
          <button className="btn" id="create-button" onClick={handleSubmit}>
            Create
          </button>
        </form>
      </div>
    </div>
  )
}
