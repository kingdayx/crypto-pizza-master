import React, {useRef, useEffect, Component, createRef } from 'react';
import { findDOMNode } from 'react-dom'
import particleNetwork from '../lib/particle'
import styled from "styled-components";

const Canvas = styled.canvas`
    background: blue;
`;

class ParticleNetwork extends Component {
  componentDidMount () {
    const container = findDOMNode(this)
    const options = {
      density: 20000,
      velocity: 0.5
    }

    new particleNetwork(container, options) // eslint-disable-line
  }

  render () {
    const { classes, id } = this.props

    return (
      <div id={id} className={classes} />
    )
  }
}



const Party = () => {
    // useEffect(() => {
    //     const { clientWidth, clientHeight } = canvas;
    //     // ctx.lineWidth = 5;
    //     ctx.strokeStyle = "blue";
    //     // ctx.strokeRect(100, 200, 150, 100);
    // })

    // function drawCanvas() {
    //     const canvas = canvasRef.current;
    //     if (canvas) {
    //       updateSize(canvas);
    //       addPlayer(canvas);
    //     }
    //   }

    const canvasRef = useRef();
    const canvy = canvasRef.current;
    const ctx = canvy.getContext('2d');
    return (
        <div>
            <Canvas ref={canvasRef} className="party"></Canvas>
            <ParticleNetwork/>
         </div>
        );
    }


export default Party;